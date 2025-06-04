//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import app_installer
import device_info_plus
import package_info_plus
import path_provider_foundation

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AppInstallerPlugin.register(with: registry.registrar(forPlugin: "AppInstallerPlugin"))
  DeviceInfoPlusMacosPlugin.register(with: registry.registrar(forPlugin: "DeviceInfoPlusMacosPlugin"))
  FPPPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FPPPackageInfoPlusPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
}
