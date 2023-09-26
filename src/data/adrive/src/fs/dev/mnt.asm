; [!] TODO [!]
; /dev/mnt device type MSD, r/w + Init + Deinit, version 2, handling no interrupts
device_file devtMSD, mDeviceReadable or mDeviceWritable or mDeviceInit or mDeviceDeinit, deviceIntNone

end device_file
