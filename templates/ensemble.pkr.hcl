packer {
  required_plugins {
    tart = {
      version = ">= 1.12.0"
      source  = "github.com/cirruslabs/tart"
    }
  }
}

variable "macos_version" {
  type = string
}

variable "xcode_version" {
  type = list(string)
}

variable "disk_size" {
  type = number
  default = 90
}

variable "vm_name" {
  type = string
}

source "tart-cli" "tart" {
  vm_base_name = "ghcr.io/cirruslabs/macos-${var.macos_version}-base:latest"
  // use tag or the last element of the xcode_version list
  vm_name      = "${var.vm_name}"
  cpu_count    = 4
  memory_gb    = 8
  disk_size_gb = var.disk_size
  headless     = true
  ssh_password = "runner"
  ssh_username = "admin"
  ssh_timeout  = "120s"
  boot_command = [
    # Skip over "Macintosh" and select "Options"
    # to boot into macOS Recovery
    "<wait60s><right><right><enter>",
    # Open Terminal
    "<wait10s><leftAltOn>T<leftAltOff>",
    # Disable SIP
    "<wait10s>csrutil disable<enter>",
    "<wait10s>y<enter>",
    "<wait10s>admin<enter>",
    # Shutdown
    "<wait10s>halt<enter>"
  ]
}

build {
  sources = ["source.tart-cli.tart"]

  provisioner "shell" {
    inline = [
      "source ~/.zprofile",
      "brew --version",
      "brew update",
      "brew upgrade",
      "brew install curl wget unzip zip ca-certificates",
      "sudo softwareupdate --install-rosetta --agree-to-license"
    ]
  }

  // Re-install the GitHub Actions runner
  provisioner "shell" {
    script = "scripts/install-actions-runner.sh"
  }

  provisioner "shell" {
    inline = [
      "source ~/.zprofile",
      "brew install xcodesorg/made/xcodes",
      "xcodes version",
    ]
  }

  provisioner "file" {
    sources      = [ for version in var.xcode_version : pathexpand("~/XcodesCache/Xcode_${version}.xip")]
    destination = "/Users/admin/Downloads/"
  }

  // iterate over all Xcode versions and install them
  // select the latest one as the default
  provisioner "shell" {
    inline = [
      for version in var.xcode_version :
      "source ~/.zprofile && sudo xcodes install ${version} --experimental-unxip --path /Users/admin/Downloads/Xcode_${version}.xip --select --empty-trash && xcodebuild -downloadAllPlatforms && xcodebuild -runFirstLaunch"
    ]
  }

  # inspired by https://github.com/actions/runner-images/blob/fb3b6fd69957772c1596848e2daaec69eabca1bb/images/macos/provision/configuration/configure-machine.sh#L33-L61
  provisioner "shell" {
    inline = [
      "source ~/.zprofile",
      "sudo security delete-certificate -Z FF6797793A3CD798DC5B2ABEF56F73EDC9F83A64 /Library/Keychains/System.keychain",
      "curl -o AppleWWDRCAG3.cer https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer",
      "curl -o DeveloperIDG2CA.cer https://www.apple.com/certificateauthority/DeveloperIDG2CA.cer",
      "curl -o add-certificate.swift https://raw.githubusercontent.com/actions/runner-images/fb3b6fd69957772c1596848e2daaec69eabca1bb/images/macos/provision/configuration/add-certificate.swift",
      "swiftc -suppress-warnings add-certificate.swift",
      "sudo ./add-certificate AppleWWDRCAG3.cer",
      "sudo ./add-certificate DeveloperIDG2CA.cer",
      "rm add-certificate* *.cer"
    ]
  }

  // check there is at least 20GB of free space and fail if not
  provisioner "shell" {
    inline = [
      "source ~/.zprofile",
      "df -h",
      "export FREE_MB=$(df -m | awk '{print $4}' | head -n 2 | tail -n 1)",
      "[[ $FREE_MB -gt 15000 ]] && echo OK || exit 1"
    ]
  }
}
