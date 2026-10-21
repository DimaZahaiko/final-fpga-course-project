# 2026-10-21T22:45:14.763830200
import vitis

client = vitis.create_client()
client.set_workspace(path="the_last_homework")

platform = client.create_platform_component(name = "platform_freq_meter",hw_design = "$COMPONENT_LOCATION/../frequency_meter/design_1_wrapper.xsa",os = "standalone",cpu = "microblaze_0",domain_name = "standalone_microblaze_0",compiler = "gcc")

platform = client.get_component(name="platform_freq_meter")
status = platform.build()

comp = client.create_app_component(name="freq_meter_component",platform = "$COMPONENT_LOCATION/../platform_freq_meter/export/platform_freq_meter/platform_freq_meter.xpfm",domain = "standalone_microblaze_0")

comp = client.get_component(name="freq_meter_component")
comp.set_app_config(key = "USER_COMPILE_SOURCES", values = ["main.c"])

status = platform.build()

comp = client.get_component(name="freq_meter_component")
comp.build()

vitis.dispose()

