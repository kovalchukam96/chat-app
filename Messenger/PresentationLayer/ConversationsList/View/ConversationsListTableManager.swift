import UIKit

final class ConversationsListTableManager: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    weak var presenter: ConversationsListViewOutput?
    
    var viewModels: [ConversationsListView.ViewModel]?
    
    var tableView: UITableView?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.numberOfRows(in: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ConversationsListCell", for: indexPath
            ) as? ConversationsListCell,
            let viewModel = presenter?.viewModel(for: indexPath)
        else  {
            return UITableViewCell()
        }
        cell.configure(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.viewModel(for: indexPath).action()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let deleteAction = presenter?.viewModel(for: indexPath).deleteAction else { return nil }
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    func beginUpdates() {
        tableView?.beginUpdates()
    }
    
    func endUpdates() {
        tableView?.endUpdates()
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
