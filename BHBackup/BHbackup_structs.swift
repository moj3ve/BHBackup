//
//  BHbackup_structs.swift
//  BHBackup
//
//  Created by BandarHelal on 11/09/1441 AH.
//  Copyright © 1441 BandarHelal. All rights reserved.
//

import Foundation
import SSZipArchive

struct WA {
    func GetDocumentPath() -> String {
        do {
            let manager = FileManager.default
            let files = try manager.contentsOfDirectory(atPath: "/var/mobile/Containers/Data/Application")
            for Data in files {
                let nextPath = "/var/mobile/Containers/Data/Application/\(Data)"
                if manager.fileExists(atPath: "\(nextPath)/Documents/StatusMessages.plist") {
                    return "\(nextPath)/Documents"
                }
            }
        } catch {
            print(error)
            return ""
        }
        return ""
    }
    func GetLibraryPath() -> String {
        do {
            let manager = FileManager.default
            let files = try manager.contentsOfDirectory(atPath: "/var/mobile/Containers/Data/Application")
            for Data in files {
                let nextPath = "/var/mobile/Containers/Data/Application/\(Data)"
                if manager.fileExists(atPath: "\(nextPath)/Library/network-usage.data") {
                    return "\(nextPath)/Library"
                }
            }
        } catch {
            print(error)
            return ""
        }
        return ""
    }
    func GetAppGroupPath() -> String {
        do {
            let manager = FileManager.default
            let files = try manager.contentsOfDirectory(atPath: "/var/mobile/Containers/Shared/AppGroup")
            for AppGroups in files {
                let nextPath = "/var/mobile/Containers/Shared/AppGroup/\(AppGroups)"
                let WAFiles = try manager.contentsOfDirectory(atPath: nextPath)
                for WAShared in WAFiles {
                    if WAShared.contains("LocalKeyValue.sqlite") {
                        let WAGroupPath = "/var/mobile/Containers/Shared/AppGroup/\(AppGroups)/"
                        return WAGroupPath
                    }
                }
            }
        } catch {
            print(error)
            return ""
        }
        return ""
    }
    func CleanDoc() {
        let semaphore = DispatchSemaphore(value: 0)
        let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let manager = FileManager.default
        let DocumentZIP = URL(fileURLWithPath: documentsDirectoryPath).appendingPathComponent("Document.zip")
        let LibraryZIP = URL(fileURLWithPath: documentsDirectoryPath).appendingPathComponent("Library.zip")
        let AppGroupZIP = URL(fileURLWithPath: documentsDirectoryPath).appendingPathComponent("AppGroup.zip")
        do {
            try manager.removeItem(at: DocumentZIP)
            try manager.removeItem(at: LibraryZIP)
            try manager.removeItem(at: AppGroupZIP)
            semaphore.signal()
        } catch {
            print(error)
            semaphore.signal()
        }
        semaphore.wait()
    }
    func MakeBackup() -> Bool {
        let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        if SSZipArchive.createZipFile(atPath: "\(documentsDirectoryPath)/Document.zip", withContentsOfDirectory: self.GetDocumentPath()) {
            if SSZipArchive.createZipFile(atPath: "\(documentsDirectoryPath)/Library.zip", withContentsOfDirectory: self.GetLibraryPath()) {
                if SSZipArchive.createZipFile(atPath: "\(documentsDirectoryPath)/AppGroup.zip", withContentsOfDirectory: self.GetAppGroupPath()) {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
    func MakeSureEverythingClean() {
        let manager = FileManager.default
        let documentsDirectoryPath = self.GetDocumentPath()
        let libraryDirectoryPath = self.GetLibraryPath()
        let semaphore = DispatchSemaphore(value: 0)
        do {
            let documentFiles = try manager.contentsOfDirectory(atPath: documentsDirectoryPath)
            let libraryFiles = try manager.contentsOfDirectory(atPath: libraryDirectoryPath)
            let appGroupFiles = try manager.contentsOfDirectory(atPath: self.GetAppGroupPath())
            if !(documentFiles.count == 0) {
                for Doc in documentFiles {
                    try manager.removeItem(at: URL(fileURLWithPath: documentsDirectoryPath).appendingPathComponent(Doc))
                }
            }
            if !(libraryFiles.count == 0 ){
                for Lib in libraryFiles {
                    try manager.removeItem(at: URL(fileURLWithPath: libraryDirectoryPath).appendingPathComponent(Lib))
                }
            }
            if !(appGroupFiles.count == 0) {
                for Group in appGroupFiles {
                    if !(Group == "Message") {
                        try manager.removeItem(at: URL(fileURLWithPath: self.GetAppGroupPath()).appendingPathComponent(Group))
                    }
                }
            }
            semaphore.signal()
        } catch {
            print(error)
            semaphore.signal()
        }
        semaphore.wait()
    }
    func MakeRestore() -> Bool {
        let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        do {
            try SSZipArchive.unzipFile(atPath: "\(documentsDirectoryPath)/Document.zip", toDestination: self.GetDocumentPath(), overwrite: true, password: nil)
            try SSZipArchive.unzipFile(atPath: "\(documentsDirectoryPath)/Library.zip", toDestination: self.GetLibraryPath(), overwrite: true, password: nil)
            try SSZipArchive.unzipFile(atPath: "\(documentsDirectoryPath)/AppGroup.zip", toDestination: self.GetAppGroupPath(), overwrite: true, password: nil)
            return true
        } catch {
            print(error)
            return false
        }
    }
}

struct installed_application {
    func getApplicationNames() -> [String] {
        var names = [String]()
        do {
            let path = "/var/containers/Bundle/Application"
            let manager = FileManager.default
            let apps = try manager.contentsOfDirectory(atPath: path)
            for app in apps {
                let content = try manager.contentsOfDirectory(atPath: "/var/containers/Bundle/Application/\(app)")
                for files in content {
                    if files.contains(".app") && !files.contains(".plist") {
                        for appFiles in try manager.contentsOfDirectory(atPath: "/var/containers/Bundle/Application/\(app)/\(files)") {
                            if appFiles == "Info.plist" {
                                let appBundle = "/var/containers/Bundle/Application/\(app)/\(files)/\(appFiles)"
                                guard let infoDictionary = NSDictionary(contentsOf: URL(fileURLWithPath: appBundle)) as? [String: Any] else {return []}
                                if let appName = infoDictionary["CFBundleDisplayName"] {
                                    names.append("\(appName)")
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            print(error)
            return []
        }
        return names
    }
    func getApplicationImage() -> [String] {
        var images = [String]()
        do {
            let path = "/var/containers/Bundle/Application"
            let manager = FileManager.default
            let apps = try manager.contentsOfDirectory(atPath: path)
            for app in apps {
                let content = try manager.contentsOfDirectory(atPath: "/var/containers/Bundle/Application/\(app)")
                for files in content {
                    if files.contains(".app") && !files.contains(".plist") {
                        for appFiles in try manager.contentsOfDirectory(atPath: "/var/containers/Bundle/Application/\(app)/\(files)") {
                            if appFiles.contains("AppIcon") && !appFiles.contains("~ipad") && !appFiles.contains("@") && !appFiles.contains("ttf") {
                                images.append(appFiles)
                            }
                        }
                    }
                }
            }
        } catch {
            print(error)
            return []
        }
        return images
    }
}

struct Zip3Sequence<E1, E2, E3>: Sequence, IteratorProtocol {
    private let _next: () -> (E1, E2, E3)?

    init<S1: Sequence, S2: Sequence, S3: Sequence>(_ s1: S1, _ s2: S2, _ s3: S3) where S1.Element == E1, S2.Element == E2, S3.Element == E3 {
        var it1 = s1.makeIterator()
        var it2 = s2.makeIterator()
        var it3 = s3.makeIterator()
        _next = {
            guard let e1 = it1.next(), let e2 = it2.next(), let e3 = it3.next() else { return nil }
            return (e1, e2, e3)
        }
    }

    mutating func next() -> (E1, E2, E3)? {
        return _next()
    }
}

func zip3<S1: Sequence, S2: Sequence, S3: Sequence>(_ s1: S1, _ s2: S2, _ s3: S3) -> Zip3Sequence<S1.Element, S2.Element, S3.Element> {
    return Zip3Sequence(s1, s2, s3)
}
