#define BLOOD_VOLUME_OVERSIZED 1120

#define PULL_OVERSIZED_SLOWDOWN 2
// Не выше, не ниже. Или ниже? HOWLING VOID
#define HUMAN_HEALTH_MODIFIER 1.0

#define HUMAN_MAXHEALTH MAX_LIVING_HEALTH * HUMAN_HEALTH_MODIFIER

#define UNDERWEAR_HIDE_SOCKS (1<<0)
#define UNDERWEAR_HIDE_SHIRT (1<<1)
#define UNDERWEAR_HIDE_UNDIES (1<<2)
#define UNDERWEAR_HIDE_BRA (1<<3)
#define UNDERWEAR_HIDE_ALL (UNDERWEAR_HIDE_SOCKS | UNDERWEAR_HIDE_SHIRT | UNDERWEAR_HIDE_UNDIES | UNDERWEAR_HIDE_BRA)

///Defines for icons used for modular bodyparts, created to make it easier to relocate the module or files if necessary.
#define BODYPART_ICON_HUMAN 'icons/bodyparts/human_parts_greyscale.dmi'
#define BODYPART_ICON_HUMANOID 'icons/bodyparts/humanoid_parts_greyscale.dmi'
#define BODYPART_ICON_MAMMAL 'icons/bodyparts/mammal_parts_greyscale.dmi'
#define BODYPART_ICON_AKULA 'icons/bodyparts/akula_parts_greyscale.dmi'
#define BODYPART_ICON_AQUATIC 'icons/bodyparts/aquatic_parts_greyscale.dmi'
#define BODYPART_ICON_GHOUL 'icons/bodyparts/ghoul_bodyparts.dmi'
#define BODYPART_ICON_INSECT 'icons/bodyparts/insect_parts_greyscale.dmi'
#define BODYPART_ICON_LIZARD 'icons/bodyparts/lizard_parts_greyscale.dmi'
#define BODYPART_ICON_MOTH 'icons/bodyparts/moth_parts_greyscale.dmi'
#define BODYPART_ICON_ROUNDSTARTSLIME 'icons/bodyparts/slime_parts_greyscale.dmi'
#define BODYPART_ICON_SKRELL 'icons/bodyparts/skrell_parts_greyscale.dmi'
#define BODYPART_ICON_TAUR 'icons/bodyparts/taur_invisible_legs.dmi'
#define BODYPART_ICON_TESHARI 'icons/bodyparts/teshari_parts_greyscale.dmi'
#define BODYPART_ICON_VOX 'icons/bodyparts/vox_parts_greyscale.dmi'
#define BODYPART_ICON_XENO 'icons/bodyparts/xeno_parts_greyscale.dmi'
#define BODYPART_ICON_SYNTHMAMMAL 'icons/bodyparts/synthmammal_parts_greyscale.dmi'
#define BODYPART_ICON_IPC 'icons/bodyparts/ipc_parts.dmi'
#define BODYPART_ICON_SYNTHLIZARD 'icons/bodyparts/synthliz_parts_greyscale.dmi'
#define BODYPART_ICON_SNAIL 'icons/bodyparts/snail_parts_greyscale.dmi'
#define BODYPART_ICON_RAMATAE 'icons/bodyparts/ramatae_parts_greyscale.dmi'
#define BODYPART_ICON_INSECTOID 'icons/bodyparts/insectoid_parts_greyscale.dmi'
///Defines for special modular bodypart variants, like harpy legs.
#define BODYPART_ICON_HARPY 'icons/bodyparts/bespoke/harpy_parts_greyscale.dmi'
#define BODYPART_ICON_HARPY_HUMAN 'icons/bodyparts/bespoke/harpy_parts_skintone.dmi'
#define BODYPART_ICON_HUMAN_CRITTER 'icons/bodyparts/bespoke/mutant_parts_skintone.dmi'
