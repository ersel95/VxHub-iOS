lazy var tableView: UITableView = {
    let table = UITableView(frame: .zero, style: .plain)
    table.backgroundColor = .black
    table.separatorStyle = .none
    table.showsVerticalScrollIndicator = false
    table.isScrollEnabled = false
    table.register(NotificationSheetCell.self, forCellReuseIdentifier: NotificationSheetCell.identifier)
    table.dataSource = self
    table.delegate = self
    table.contentInset = .zero
    table.contentInsetAdjustmentBehavior = .never
    if #available(iOS 15.0, *) {
        table.sectionHeaderTopPadding = 0
    }
    return table
}()

func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0
}

func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0
}

func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return nil
}

func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return nil
} 