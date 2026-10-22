# 2026-10-22T10:53:05.537813600
import vitis

client = vitis.create_client()
client.set_workspace(path="the_last_homework")

platform = client.get_component(name="platform_freq_meter")
status = platform.build()

comp = client.get_component(name="freq_meter_component")
comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

