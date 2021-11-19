{ self
, system
, ...
}@inputs:

imageName:
{
  inherit inputs system;
  nixpie = self;
  inherit imageName;
}
