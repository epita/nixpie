{ pkgs, ... }:

let
  csproject = pkgs.writeText "Test.csproj" ''
    <Project Sdk="Microsoft.NET.Sdk">
      <PropertyGroup>
        <OutputType>Exe</OutputType>
        <TargetFramework>net7.0</TargetFramework>
      </PropertyGroup>
    </Project>
  '';
  program = pkgs.writeText "Program.cs" ''
    using System;

    class TestClass
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Test successful!");
        }
    }
  '';
in
{
  nodes.machine = { config, pkgs, ... }: {
    cri.packages.pkgs.csharp.enable = true;
  };

  testScript = ''
    start_all()
    machine.succeed("cp ${csproject} ${csproject.name}")
    machine.succeed("cp ${program} ${program.name}")
    machine.succeed("dotnet build")
    machine.succeed("./bin/Debug/net7.0/Test")
  '';
}
