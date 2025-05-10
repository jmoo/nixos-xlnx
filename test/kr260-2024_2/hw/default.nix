{
  pkgs,
  ...
}:
{

  hardware.zynq = {
    platform = pkgs.nixos-xlnx.xilinx-platforms.zynqmp;
    bitstream = ./sdt/kria_kr260_bd_wrapper.bit;
    sdtDir = ./sdt;
    dtDir = ./dt;
  };

  hardware.deviceTree.overlays = [
    {
      name = "system-user";
      dtsFile = ./system-user.dts;
    }
  ];
}
