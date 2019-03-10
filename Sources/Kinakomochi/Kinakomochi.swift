import S3
import Foundation

extension String {
    
    var isDir: Bool {
        var _isDir = ObjCBool(false)
        let exists = FileManager.default.fileExists(atPath: self, isDirectory: &_isDir)
        return exists ? _isDir.boolValue : false
    }
}

public func backup() {
    
    guard let accessKeyId = ProcessInfo.processInfo.environment["AWS_ACCESS_KEY_ID"],
        let secretAccessKey = ProcessInfo.processInfo.environment["AWS_SECRET_ACCESS_KEY"] else {
        fatalError("Credentials not set")
    }
    
    guard let bucket = ProcessInfo.processInfo.environment["S3_BUCKET"] else {
        fatalError("Bucket not set")
    }
    
    guard let basePath = ProcessInfo.processInfo.environment["BASE_PATH"]  else {
        fatalError("BasePath not set")
    }
    
    guard let backupDirectory = ProcessInfo.processInfo.environment["BACK_UP_DIR"] else {
        fatalError("Backup Directory not set")
    }
    
    func enumerateFiles(in directory: String) throws -> [String] {
        var files = [String]()
        var nestedDirectories = [String]()
        let contents = try FileManager.default.contentsOfDirectory(atPath: directory)
        for content in contents {
            let path = directory.appending("/").appending(content)
            if path.isDir {
                nestedDirectories.append(path)
            } else {
                files.append(path)
            }
        }
        for nested in nestedDirectories {
            files.append(contentsOf: try enumerateFiles(in: nested))
        }
        return files
    }
    
    do {
        let files = try enumerateFiles(in: backupDirectory)
        let s3 = S3(accessKeyId: accessKeyId, secretAccessKey: secretAccessKey, region: .apnortheast1)
        
        for file in files {
            guard let data = FileManager.default.contents(atPath: file) else {
                print("\(file) has invalid data, check the file path and data")
                continue
            }
            let pathBasedBackup = file.replacingOccurrences(of: backupDirectory, with: "")
            let key = basePath.appending(pathBasedBackup)
            let request = S3.PutObjectRequest(acl: .private, bucket: bucket, contentLength: Int64(data.count), key: key, body: data)
            do {
                _ = try s3.putObject(request)
            } catch {
                print("Upload Error at \(file)", error)
                continue
            }
            print("Upload Succeeded at \(file)")
            do {
                try FileManager.default.removeItem(atPath: file)
                print("Remove Succeeded at \(file)")
            } catch {
                print("Remove Error at \(file)", error)
            }
        }
    } catch {
        print(error)
    }
}
