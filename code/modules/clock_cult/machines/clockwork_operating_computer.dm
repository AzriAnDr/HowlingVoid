/obj/machinery/computer/operating/clockwork
	name = "Clockwork Operating Computer"
	desc = "A device containing most of the surgery secrets of the universe."
	color = rgb(190, 135, 0)
	circuit = /obj/item/circuitboard/computer/operating/clockwork

/obj/machinery/computer/operating/clockwork/Initialize(mapload)
	. = ..()
	advanced_surgeries |= subtypesof(/datum/surgery_operation)
	advanced_surgeries -= subtypesof(/datum/surgery_operation/basic/revival)

/obj/item/circuitboard/computer/operating/clockwork
	name = "Clockwork Operating Computer"
	build_path = /obj/machinery/computer/operating/clockwork
