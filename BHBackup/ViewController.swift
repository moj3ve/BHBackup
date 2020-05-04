//
//  ViewController.swift
//  BHBackup
//
//  Created by BandarHelal on 11/09/1441 AH.
//  Copyright © 1441 BandarHelal. All rights reserved.
//

import UIKit
import SSZipArchive

class ViewController: UIViewController {
    var files: [URL]?
    var appsTable = UITableView()
    
    @IBOutlet weak var empyTable: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appsTable = UITableView(frame: self.view.frame, style: .insetGrouped)
        self.appsTable.delegate = self
        self.appsTable.dataSource = self
        self.appsTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.appsTable)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(WA().GetLibraryPath(), WA().GetDocumentPath(), WA().GetAppGroupPath())
        if self.files == nil {
            self.view.sendSubviewToBack(self.appsTable)
        } else {
            self.view.sendSubviewToBack(self.empyTable)
        }
        self.SetupDocumentsDirectoryPath()
    }
    func SetupDocumentsDirectoryPath() {
        let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        files = [URL]()
        let fileManager = FileManager.default
        let documentsURL = URL(string: documentsDirectoryPath)
        
        do {
            try files = fileManager.contentsOfDirectory(at: documentsURL!, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
        } catch {
            print("error wtih \(error)")
        }
        
        DispatchQueue.main.async {
            self.appsTable.reloadData()
            if self.files?.count == 0 {
                self.view.sendSubviewToBack(self.appsTable)
            } else {
                self.view.sendSubviewToBack(self.empyTable)
            }
        }
    }
    
    @IBAction func createBackup(_ sender: Any) {
        let confirmAlert = UIAlertController(title: "This is a confirm alert", message: "Use of this tool is at your own risk, and I am not responsible for losing any data to you.", preferredStyle: .alert)
        confirmAlert.addAction(.init(title: "Confirm", style: .default, handler: { (_) in
            WA().CleanDoc()
            if WA().MakeBackup() {
                self.SetupDocumentsDirectoryPath()
            } else {
                let alert = UIAlertController(title: "HI", message: "something error :)", preferredStyle: .alert)
                alert.addAction(.init(title: "ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        confirmAlert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(confirmAlert, animated: true, completion: nil)
    }
    
    @IBAction func Restore(_ sender: Any) {
        let confirmAlert = UIAlertController(title: "This is a confirm alert", message: "Use of this tool is at your own risk, and I am not responsible for losing any data to you.", preferredStyle: .alert)
        confirmAlert.addAction(.init(title: "Confirm", style: .default, handler: { (_) in
            if WA().MakeRestore() {
                let doneAlert = UIAlertController(title: "Hi", message: "Successfully Restoring files \n now close WhatsApp and open it agin.", preferredStyle: .alert)
                doneAlert.addAction(.init(title: "OK, thanks", style: .default, handler: nil))
                self.present(doneAlert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "HI", message: "something error :)", preferredStyle: .alert)
                alert.addAction(.init(title: "ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        confirmAlert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(confirmAlert, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = self.files?[indexPath.row].lastPathComponent
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ac = UIActivityViewController(activityItems: [self.files![indexPath.row]], applicationActivities: nil)
        
        self.present(ac, animated: true) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
