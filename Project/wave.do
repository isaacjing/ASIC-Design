onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_flashmemorycontroller/tb_clk_usb
add wave -noupdate /tb_flashmemorycontroller/tb_clk_fcu
add wave -noupdate /tb_flashmemorycontroller/Status
add wave -noupdate /tb_flashmemorycontroller/Request
add wave -noupdate /tb_flashmemorycontroller/Output
add wave -noupdate /tb_flashmemorycontroller/Reset
add wave -noupdate /tb_flashmemorycontroller/Input
add wave -noupdate /tb_flashmemorycontroller/Address
add wave -noupdate /tb_flashmemorycontroller/Error
add wave -noupdate /tb_flashmemorycontroller/EmptyFlag
add wave -noupdate /tb_flashmemorycontroller/Full
add wave -noupdate /tb_flashmemorycontroller/FDataIn
add wave -noupdate /tb_flashmemorycontroller/FDataOut
add wave -noupdate /tb_flashmemorycontroller/FDataOE2
add wave -noupdate /tb_flashmemorycontroller/FDataOE
add wave -noupdate /tb_flashmemorycontroller/RE_n
add wave -noupdate /tb_flashmemorycontroller/WE_n
add wave -noupdate /tb_flashmemorycontroller/ALE
add wave -noupdate /tb_flashmemorycontroller/temp
add wave -noupdate /tb_flashmemorycontroller/CLE
add wave -noupdate /tb_flashmemorycontroller/CE_n
add wave -noupdate /tb_flashmemorycontroller/WP_n
add wave -noupdate /tb_flashmemorycontroller/RB
add wave -noupdate -radix unsigned /tb_flashmemorycontroller/Byte
add wave -noupdate /tb_flashmemorycontroller/OutputShift
add wave -noupdate /tb_flashmemorycontroller/TC
add wave -noupdate /tb_flashmemorycontroller/lcv
add wave -noupdate /tb_flashmemorycontroller/io
add wave -noupdate -radix hexadecimal /tb_flashmemorycontroller/io
add wave -noupdate /tb_flashmemorycontroller/Output_Selection
add wave -noupdate /tb_flashmemorycontroller/Length
add wave -noupdate -radix unsigned /tb_flashmemorycontroller/DIU/fcu1/state
add wave -noupdate /tb_flashmemorycontroller/FLASH/Add1
add wave -noupdate /tb_flashmemorycontroller/FLASH/Add2
add wave -noupdate /tb_flashmemorycontroller/FLASH/Add3
add wave -noupdate /tb_flashmemorycontroller/FLASH/Add4
add wave -noupdate -radix unsigned /tb_flashmemorycontroller/FLASH/temp
add wave -noupdate /tb_flashmemorycontroller/FLASH/Command
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {14343970000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {14343458 ns} {14344482 ns}
