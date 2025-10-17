###############################################################
#  File for placement of IOs
#  Can be scripted or written out from Innovus
#  Command:           write_io_file -locations ../inputs/ioring.io
###############################################################

(globals
    version = 3
    io_order = default
)
(iopad
    (topright
	(inst name="i_ioring/i_PCORNER_NE"	)
    )
    (top
	(inst  name="i_ioring/i_CLOCK_EN"	offset=329.1700 place_status=placed )
	# Similar syntax for all IOs.
    )
    (topleft
	(inst name="i_ioring/i_PCORNER_NW"	)
    )
    (left
	(inst  name="i_ioring/i_EXT_PERF_COUNTERS_10"	offset=161.7650 place_status=placed )
	# Similar syntax for all IOs.
    )
    (bottomleft
	(inst name="i_ioring/i_PCORNER_SW"	)
    )
    (bottom
	(inst  name="i_ioring/i_VDDCORE_53"	offset=2630.0000 place_status=placed )
	# Similar syntax for all IOs.
    )
    (bottomright
	(inst name="i_ioring/i_PCORNER_SE"	)
    )
    (right
	(inst  name="i_ioring/i_VDDCORE_61"	offset=120.0000 place_status=placed )
	# Similar syntax for all IOs.
    )
)
