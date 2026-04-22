#!/usr/bin/env python3
"""
DMI Merge Driver - Three-way merge tool for BYOND/DreamMaker icon files (.dmi)

This tool performs intelligent merging of DMI sprite files, handling:
- Icon state additions/deletions/modifications
- Conflict detection with clear markers
- Both Git merge driver mode and standalone file merging

Usage:
    As Git merge driver (automatic via hooks):
        python -m dmi.merge_driver %P %O %A %B %L

    Post-hoc conflict resolution:
        python -m dmi.merge_driver --posthoc

    Direct file merge (standalone):
        python -m dmi.merge_driver --merge <base.dmi> <left.dmi> <right.dmi> <output.dmi>

    Copy states from one DMI to another:
        python -m dmi.merge_driver --copy-states <source.dmi> <target.dmi> [--states state1,state2,...]

Dependencies:
    - Pillow (PIL)
    - pygit2 (for Git integration only)
"""
import sys
import os
import argparse

# Add tools directory to path for proper imports
_tools_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _tools_dir not in sys.path:
    sys.path.insert(0, _tools_dir)

import dmi
# Lazy import: MergeDriver is only needed for Git integration (--posthoc mode)
# from hooks.merge_frontend import MergeDriver


def images_equal(left, right):
    """
    Compare two PIL images pixel-by-pixel.
    Ignores differences in fully transparent pixels (alpha=0).

    Returns:
        bool: True if images are visually identical, False otherwise
    """
    if left.size != right.size:
        return False
    w, h = left.size
    left_load, right_load = left.load(), right.load()
    for y in range(0, h):
        for x in range(0, w):
            lpixel, rpixel = left_load[x, y], right_load[x, y]
            # quietly ignore changes where both pixels are fully transparent
            if lpixel != rpixel and (lpixel[3] != 0 or rpixel[3] != 0):
                return False
    return True


def states_equal(left, right):
    """
    Compare two DMI states for equality.
    Checks all properties (loop, rewind, movement, dirs, delays, hotspots, framecount)
    and all frame images.

    Returns:
        bool: True if states are identical, False otherwise
    """
    result = True

    # basic properties
    for attr in ('loop', 'rewind', 'movement', 'dirs', 'delays', 'hotspots', 'framecount'):
        lval, rval = getattr(left, attr), getattr(right, attr)
        if lval != rval:
            result = False

    # frames
    for (left_frame, right_frame) in zip(left.frames, right.frames):
        if not images_equal(left_frame, right_frame):
            result = False

    return result


def key_of(state):
    """Create a unique key for a state based on name and movement flag."""
    return (state.name, state.movement)


def dictify(sheet):
    """
    Convert a DMI's states list into a dictionary keyed by (name, movement).
    Warns about duplicate states.
    """
    result = {}
    for state in sheet.states:
        k = key_of(state)
        if k in result:
            print(f"    WARNING: duplicate state {k!r}")
        result[k] = state
    return result


def three_way_merge(base, left, right, verbose=True):
    """
    Perform a three-way merge of DMI files.

    Args:
        base: Base (common ancestor) DMI object
        left: Left (ours) DMI object
        right: Right (theirs) DMI object
        verbose: Whether to print detailed merge information

    Returns:
        tuple: (conflict_count, merged_dmi)
            - conflict_count: Number of conflicts (0 = success), or True if merge impossible
            - merged_dmi: Merged DMI object, or None if merge was impossible
    """
    def log(msg):
        if verbose:
            print(msg)
    base_dims = base.width, base.height
    if base_dims != (left.width, left.height) or base_dims != (right.width, right.height):
        log("Dimensions have changed:")
        log(f"    Base: {base.width} x {base.height}")
        log(f"    Ours: {left.width} x {left.height}")
        log(f"    Theirs: {right.width} x {right.height}")
        return True, None

    base_states, left_states, right_states = dictify(base), dictify(left), dictify(right)

    new_left = {k: v for k, v in left_states.items() if k not in base_states}
    new_right = {k: v for k, v in right_states.items() if k not in base_states}
    new_both = {}
    conflicts = []
    for key, state in list(new_left.items()):
        in_right = new_right.get(key, None)
        if in_right:
            if states_equal(state, in_right):
                # allow it
                new_both[key] = state
            else:
                # generate conflict states
                log(f" C: {state.name!r}: added differently in both!")
                state.name = f"{state.name} !CONFLICT! left"
                conflicts.append(state)
                in_right.name = f"{state.name} !CONFLICT! right"
                conflicts.append(in_right)
            # don't add it a second time
            del new_left[key]
            del new_right[key]

    final_states = []
    # add states that are currently in the base
    for state in base.states:
        in_left = left_states.get(key_of(state), None)
        in_right = right_states.get(key_of(state), None)
        left_equals = in_left and states_equal(state, in_left)
        right_equals = in_right and states_equal(state, in_right)

        if not in_left and not in_right:
            # deleted in both left and right, it's just deleted
            log(f"    {state.name!r}: deleted in both")
        elif not in_left:
            # left deletes
            log(f"    {state.name!r}: deleted in left")
            if not right_equals:
                log(f"    ... but modified in right")
                final_states.append(in_right)
        elif not in_right:
            # right deletes
            log(f"    {state.name!r}: deleted in right")
            if not left_equals:
                log(f"    ... but modified in left")
                final_states.append(in_left)
        elif left_equals and right_equals:
            # changed in neither
            final_states.append(state)
        elif left_equals:
            # changed only in right
            log(f"    {state.name!r}: changed in right")
            final_states.append(in_right)
        elif right_equals:
            # changed only in left
            log(f"    {state.name!r}: changed in left")
            final_states.append(in_left)
        elif states_equal(in_left, in_right):
            # changed in both, to the same thing
            log(f"    {state.name!r}: changed same in both")
            final_states.append(in_left)  # either or
        else:
            # changed in both
            name = state.name
            log(f" C: {name!r}: changed differently in both!")
            state.name = f"{name} !CONFLICT! base"
            conflicts.append(state)
            in_left.name = f"{name} !CONFLICT! left"
            conflicts.append(in_left)
            in_right.name = f"{name} !CONFLICT! right"
            conflicts.append(in_right)

    # add states which both left and right added the same
    for key, state in new_both.items():
        log(f"    {state.name!r}: added same in both")
        final_states.append(state)

    # add states that are brand-new in the left
    for key, state in new_left.items():
        log(f"    {state.name!r}: added in left")
        final_states.append(state)

    # add states that are brand-new in the right
    for key, state in new_right.items():
        log(f"    {state.name!r}: added in right")
        final_states.append(state)

    final_states.extend(conflicts)
    merged = dmi.Dmi(base.width, base.height)
    merged.states = final_states
    return len(conflicts), merged


def copy_states(source_path, target_path, output_path=None, state_names=None, overwrite=True, verbose=True):
    """
    Copy icon states from one DMI file to another.

    Args:
        source_path: Path to source DMI file
        target_path: Path to target DMI file
        output_path: Path for output file (defaults to target_path)
        state_names: List of state names to copy (None = all states)
        overwrite: Whether to overwrite existing states in target
        verbose: Whether to print detailed information

    Returns:
        tuple: (success, copied_count, skipped_count)
    """
    if output_path is None:
        output_path = target_path

    def log(msg):
        if verbose:
            print(msg)

    try:
        source = dmi.Dmi.from_file(source_path)
        target = dmi.Dmi.from_file(target_path)
    except Exception as e:
        log(f"Error loading DMI files: {e}")
        return False, 0, 0

    # Check dimensions
    if (source.width, source.height) != (target.width, target.height):
        log(f"WARNING: Dimension mismatch!")
        log(f"    Source: {source.width}x{source.height}")
        log(f"    Target: {target.width}x{target.height}")
        log("    States will be copied but may not display correctly.")

    target_keys = {key_of(s) for s in target.states}
    copied = 0
    skipped = 0

    for state in source.states:
        # Filter by state names if specified
        if state_names and state.name not in state_names:
            continue

        key = key_of(state)
        if key in target_keys:
            if overwrite:
                # Remove existing state
                target.states = [s for s in target.states if key_of(s) != key]
                target.states.append(state)
                log(f"    Overwrote: {state.name!r}")
                copied += 1
            else:
                log(f"    Skipped (exists): {state.name!r}")
                skipped += 1
        else:
            target.states.append(state)
            log(f"    Copied: {state.name!r}")
            copied += 1

    try:
        target.to_file(output_path)
        log(f"Saved to: {output_path}")
        log(f"Copied: {copied}, Skipped: {skipped}")
        return True, copied, skipped
    except Exception as e:
        log(f"Error saving file: {e}")
        return False, copied, skipped


def merge_files(base_path, left_path, right_path, output_path, verbose=True):
    """
    Perform a three-way merge of DMI files directly (standalone mode).

    Args:
        base_path: Path to base (common ancestor) DMI file
        left_path: Path to left (ours) DMI file
        right_path: Path to right (theirs) DMI file
        output_path: Path for merged output file
        verbose: Whether to print detailed merge information

    Returns:
        tuple: (success, conflict_count)
    """
    def log(msg):
        if verbose:
            print(msg)

    try:
        log(f"Loading base: {base_path}")
        base = dmi.Dmi.from_file(base_path)
        log(f"Loading left (ours): {left_path}")
        left = dmi.Dmi.from_file(left_path)
        log(f"Loading right (theirs): {right_path}")
        right = dmi.Dmi.from_file(right_path)
    except Exception as e:
        log(f"Error loading DMI files: {e}")
        return False, -1

    log("Performing three-way merge...")
    conflicts, merged = three_way_merge(base, left, right, verbose=verbose)

    if merged is None:
        log("Merge failed completely (dimension mismatch)")
        return False, -1

    try:
        merged.to_file(output_path)
        log(f"Saved merged result to: {output_path}")
        if conflicts:
            log(f"WARNING: {conflicts} conflict(s) detected!")
            log("    Edit the output file and remove states marked with !CONFLICT!")
        else:
            log("Merge completed successfully with no conflicts.")
        return conflicts == 0, conflicts
    except Exception as e:
        log(f"Error saving merged file: {e}")
        return False, -1


def list_states(dmi_path, verbose=True):
    """
    List all icon states in a DMI file.

    Args:
        dmi_path: Path to DMI file
        verbose: Whether to print detailed information

    Returns:
        list: List of state names
    """
    def log(msg):
        if verbose:
            print(msg)

    try:
        icon = dmi.Dmi.from_file(dmi_path)
    except Exception as e:
        log(f"Error loading DMI file: {e}")
        return []

    log(f"DMI: {dmi_path}")
    log(f"Dimensions: {icon.width}x{icon.height}")
    log(f"States ({len(icon.states)}):")

    names = []
    for state in icon.states:
        names.append(state.name)
        movement = " [movement]" if state.movement else ""
        dirs = f"{state.dirs}dir" if state.dirs > 1 else ""
        frames = f"{state.framecount}f" if state.framecount > 1 else ""
        info = ", ".join(filter(None, [dirs, frames]))
        if info:
            info = f" ({info})"
        log(f"    {state.name!r}{movement}{info}")

    return names


def rename_states(dmi_path, renames, output_path=None, verbose=True):
    """
    Rename icon states in a DMI file.

    Args:
        dmi_path: Path to DMI file
        renames: Dictionary mapping old names to new names {old_name: new_name}
        output_path: Path for output file (defaults to dmi_path, overwriting)
        verbose: Whether to print detailed information

    Returns:
        tuple: (success, renamed_count, not_found_list)
    """
    if output_path is None:
        output_path = dmi_path

    def log(msg):
        if verbose:
            print(msg)

    try:
        icon = dmi.Dmi.from_file(dmi_path)
    except Exception as e:
        log(f"Error loading DMI file: {e}")
        return False, 0, []

    log(f"DMI: {dmi_path}")
    log(f"Renaming {len(renames)} state(s)...")

    renamed = 0
    not_found = []
    existing_names = {s.name for s in icon.states}

    for old_name, new_name in renames.items():
        if old_name not in existing_names:
            log(f"    NOT FOUND: {old_name!r}")
            not_found.append(old_name)
            continue

        if new_name in existing_names and new_name != old_name:
            log(f"    CONFLICT: {old_name!r} -> {new_name!r} (target already exists)")
            not_found.append(old_name)
            continue

        for state in icon.states:
            if state.name == old_name:
                state.name = new_name
                log(f"    Renamed: {old_name!r} -> {new_name!r}")
                renamed += 1
                # Update existing_names set
                existing_names.discard(old_name)
                existing_names.add(new_name)
                break

    if renamed > 0:
        try:
            icon.to_file(output_path)
            log(f"Saved to: {output_path}")
        except Exception as e:
            log(f"Error saving file: {e}")
            return False, renamed, not_found

    log(f"Renamed: {renamed}, Not found: {len(not_found)}")
    return True, renamed, not_found


def delete_states(dmi_path, state_names, output_path=None, verbose=True):
    """
    Delete icon states from a DMI file.

    Args:
        dmi_path: Path to DMI file
        state_names: List of state names to delete
        output_path: Path for output file (defaults to dmi_path, overwriting)
        verbose: Whether to print detailed information

    Returns:
        tuple: (success, deleted_count, not_found_list)
    """
    if output_path is None:
        output_path = dmi_path

    def log(msg):
        if verbose:
            print(msg)

    try:
        icon = dmi.Dmi.from_file(dmi_path)
    except Exception as e:
        log(f"Error loading DMI file: {e}")
        return False, 0, []

    log(f"DMI: {dmi_path}")
    log(f"Deleting {len(state_names)} state(s)...")

    deleted = 0
    not_found = []
    existing_names = {s.name for s in icon.states}

    for name in state_names:
        if name not in existing_names:
            log(f"    NOT FOUND: {name!r}")
            not_found.append(name)
            continue

        icon.states = [s for s in icon.states if s.name != name]
        log(f"    Deleted: {name!r}")
        deleted += 1
        existing_names.discard(name)

    if deleted > 0:
        try:
            icon.to_file(output_path)
            log(f"Saved to: {output_path}")
        except Exception as e:
            log(f"Error saving file: {e}")
            return False, deleted, not_found

    log(f"Deleted: {deleted}, Not found: {len(not_found)}")
    return True, deleted, not_found


def bulk_rename_pattern(dmi_path, pattern, replacement, output_path=None, verbose=True):
    """
    Rename states matching a pattern (prefix/suffix replacement).

    Args:
        dmi_path: Path to DMI file
        pattern: Pattern to find in state names (simple string, not regex)
        replacement: String to replace pattern with
        output_path: Path for output file (defaults to dmi_path)
        verbose: Whether to print detailed information

    Returns:
        tuple: (success, renamed_count)
    """
    if output_path is None:
        output_path = dmi_path

    def log(msg):
        if verbose:
            print(msg)

    try:
        icon = dmi.Dmi.from_file(dmi_path)
    except Exception as e:
        log(f"Error loading DMI file: {e}")
        return False, 0

    log(f"DMI: {dmi_path}")
    log(f"Pattern: {pattern!r} -> {replacement!r}")

    renamed = 0
    existing_names = {s.name for s in icon.states}

    for state in icon.states:
        if pattern in state.name:
            new_name = state.name.replace(pattern, replacement)
            if new_name != state.name and new_name not in existing_names:
                old_name = state.name
                existing_names.discard(old_name)
                state.name = new_name
                existing_names.add(new_name)
                log(f"    Renamed: {old_name!r} -> {new_name!r}")
                renamed += 1
            elif new_name in existing_names:
                log(f"    SKIP (conflict): {state.name!r} -> {new_name!r}")

    if renamed > 0:
        try:
            icon.to_file(output_path)
            log(f"Saved to: {output_path}")
        except Exception as e:
            log(f"Error saving file: {e}")
            return False, renamed

    log(f"Renamed: {renamed} state(s)")
    return True, renamed


# DmiDriver is created lazily because it requires pygit2 (via MergeDriver)
_DmiDriver = None

def _get_dmi_driver():
    """Get DmiDriver class, creating it lazily on first use."""
    global _DmiDriver
    if _DmiDriver is None:
        from hooks.merge_frontend import MergeDriver

        class DmiDriver(MergeDriver):
            driver_id = 'dmi'

            def merge(self, base, left, right):
                icon_base = dmi.Dmi.from_file(base)
                icon_left = dmi.Dmi.from_file(left)
                icon_right = dmi.Dmi.from_file(right)
                trouble, merge_result = three_way_merge(icon_base, icon_left, icon_right)
                return not trouble, merge_result

            def to_file(self, outfile, merge_result):
                merge_result.to_file(outfile)

            def post_announce(self, success, merge_result):
                if not success:
                    print("!!! Manual merge required!")
                    if merge_result:
                        print("    A best-effort merge was performed. You must edit the icon and remove all")
                        print("    icon states marked with !CONFLICT!, leaving only the desired icon.")
                    else:
                        print("    The icon was totally unable to be merged, you must start with one version")
                        print("    or the other and manually resolve the conflict.")
                    print("    Information about which states conflicted is listed above.")

        _DmiDriver = DmiDriver
    return _DmiDriver


def _parse_args():
    """Parse command-line arguments for standalone usage."""
    parser = argparse.ArgumentParser(
        description="DMI Merge Driver - Tool for merging and editing BYOND icon files",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  List states in a DMI:
    python -m dmi.merge_driver --list icons/mob/human.dmi

  Three-way merge:
    python -m dmi.merge_driver --merge base.dmi ours.dmi theirs.dmi output.dmi

  Copy all states from source to target:
    python -m dmi.merge_driver --copy-states source.dmi target.dmi

  Copy specific states:
    python -m dmi.merge_driver --copy-states source.dmi target.dmi --states "state1,state2"

  Rename a single state:
    python -m dmi.merge_driver --rename file.dmi "old_name:new_name"

  Rename multiple states:
    python -m dmi.merge_driver --rename file.dmi "old1:new1,old2:new2"

  Bulk rename with pattern:
    python -m dmi.merge_driver --rename-pattern file.dmi "_old" "_new"

  Delete states:
    python -m dmi.merge_driver --delete file.dmi "state1,state2"

  Git post-hoc conflict resolution:
    python -m dmi.merge_driver --posthoc
        """
    )

    parser.add_argument('--posthoc', action='store_true',
                        help='Resolve conflicts in repository (Git integration)')
    parser.add_argument('--merge', nargs=4, metavar=('BASE', 'LEFT', 'RIGHT', 'OUTPUT'),
                        help='Perform three-way merge of DMI files')
    parser.add_argument('--copy-states', nargs=2, metavar=('SOURCE', 'TARGET'),
                        help='Copy states from source DMI to target DMI')
    parser.add_argument('--states', type=str, default=None,
                        help='Comma-separated list of state names (for --copy-states)')
    parser.add_argument('--output', '-o', type=str, default=None,
                        help='Output file path (default: overwrite input)')
    parser.add_argument('--no-overwrite', action='store_true',
                        help='Do not overwrite existing states (for --copy-states)')
    parser.add_argument('--list', type=str, metavar='DMI_FILE',
                        help='List all states in a DMI file')

    # Rename operations
    parser.add_argument('--rename', nargs=2, metavar=('DMI_FILE', 'MAPPINGS'),
                        help='Rename states. MAPPINGS: "old1:new1,old2:new2"')
    parser.add_argument('--rename-pattern', nargs=3, metavar=('DMI_FILE', 'PATTERN', 'REPLACEMENT'),
                        help='Bulk rename: replace PATTERN with REPLACEMENT in all state names')

    # Delete operation
    parser.add_argument('--delete', nargs=2, metavar=('DMI_FILE', 'STATES'),
                        help='Delete states. STATES: comma-separated list "state1,state2"')

    parser.add_argument('--quiet', '-q', action='store_true',
                        help='Suppress detailed output')

    # For Git merge driver mode (called by Git)
    parser.add_argument('git_args', nargs='*', help=argparse.SUPPRESS)

    return parser.parse_args()


def main():
    """Main entry point with support for multiple operation modes."""
    args = _parse_args()
    verbose = not args.quiet

    # List states mode
    if args.list:
        states = list_states(args.list, verbose=verbose)
        return 0 if states or states == [] else 1

    # Three-way merge mode
    if args.merge:
        base, left, right, output = args.merge
        success, conflicts = merge_files(base, left, right, output, verbose=verbose)
        return 0 if success else 1

    # Copy states mode
    if args.copy_states:
        source, target = args.copy_states
        state_names = args.states.split(',') if args.states else None
        output = args.output or target
        success, copied, skipped = copy_states(
            source, target, output,
            state_names=state_names,
            overwrite=not args.no_overwrite,
            verbose=verbose
        )
        return 0 if success else 1

    # Rename states mode
    if args.rename:
        dmi_file, mappings_str = args.rename
        # Parse mappings: "old1:new1,old2:new2"
        renames = {}
        for mapping in mappings_str.split(','):
            if ':' not in mapping:
                print(f"Invalid mapping format: {mapping!r} (expected 'old:new')")
                return 1
            old, new = mapping.split(':', 1)
            renames[old.strip()] = new.strip()
        output = args.output or dmi_file
        success, renamed, not_found = rename_states(dmi_file, renames, output, verbose=verbose)
        return 0 if success and not not_found else 1

    # Bulk rename pattern mode
    if args.rename_pattern:
        dmi_file, pattern, replacement = args.rename_pattern
        output = args.output or dmi_file
        success, renamed = bulk_rename_pattern(dmi_file, pattern, replacement, output, verbose=verbose)
        return 0 if success else 1

    # Delete states mode
    if args.delete:
        dmi_file, states_str = args.delete
        state_names = [s.strip() for s in states_str.split(',')]
        output = args.output or dmi_file
        success, deleted, not_found = delete_states(dmi_file, state_names, output, verbose=verbose)
        return 0 if success else 1

    # Post-hoc mode (Git integration)
    if args.posthoc:
        DmiDriver = _get_dmi_driver()
        return DmiDriver().main(['--posthoc'])

    # Git merge driver mode (when called by Git with positional args)
    if args.git_args:
        DmiDriver = _get_dmi_driver()
        return DmiDriver().main(args.git_args)

    # No mode specified, show help
    _parse_args().parse_args(['--help'])
    return 1


if __name__ == '__main__':
    exit(main())
