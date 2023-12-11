import UIKit

final class ConversationTableManager: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    weak var presenter: ConversationViewOutput?
    
    var tableView: UITableView?
    
    func scrollToBottom() {
        let section = presenter?.numberOfSections() ?? 1
        let row = presenter?.numberOfRows(in: section - 1) ?? 1
        guard row > 1 else { return }
        tableView?.scrollToRow(
            at: .init(
                row: row - 1,
                section: section - 1
            ),
            at: .bottom,
            animated: true
        )
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        presenter?.numberOfSections() ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.numberOfRows(in: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ConversationCell", for: indexPath
            ) as? ConversationCell,
            let viewModel = presenter?.viewModel(for: indexPath)
        else  {
            return UITableViewCell()
        }
        
        cell.configure(with: viewModel)
        return cell
    }
    
    func beginUpdates() {
        tableView?.beginUpdates()
    }
    
    func endUpdates() {
        tableView?.endUpdates()
        scrollToBottom()
    }
    
    func insertRow(at indexPath: IndexPath) {
        tableView?.insertRows(at: [indexPath], with: .automatic)
    }
    
    func deleteRow(at indexPath: IndexPath) {
        tableView?.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func reloadRow(at indexPath: IndexPath) {
        tableView?.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        tableView?.deleteRows(at: [indexPath], with: .fade)
        tableView?.insertRows(at: [newIndexPath], with: .fade)
    }
    
}
