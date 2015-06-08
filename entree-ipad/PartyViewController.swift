
import UIKit

class PartyViewController: UITableViewController {
    
    var orders = [Order]()
    var party: Party!
    var tickets = [Ticket]()

    // MARK: - PartyViewController
    
    private func loadOrders() {
        let query = Order.query()!
        query.limit = 1000
        
        query.includeKey("menuItem")
        query.includeKey("ticket")
        
        let innerQuery = Ticket.query()!
        innerQuery.whereKey("party", equalTo: party)
        innerQuery.whereKey("restaurant", equalTo: Restaurant.sharedRestaurant())
        
        query.whereKey("ticket", matchesQuery: innerQuery)
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) in
            if let orders = objects as? [Order] {
                self.orders = orders
                
                self.tickets.removeAll(keepCapacity: false)
                for order in orders {
                    self.tickets.append(order.ticket)
                }
                var ticketObjectIdToExistsMap = [String: Bool]()
                self.tickets = self.tickets.filter { (ticket: Ticket) -> Bool in
                    if ticketObjectIdToExistsMap[ticket.objectId!] == true {
                        return false
                    } else {
                        ticketObjectIdToExistsMap[ticket.objectId!] = true
                        return true
                    }
                }
                self.tickets.sort { (first: Ticket, second: Ticket) -> Bool in
                    return first.createdAt!.timeIntervalSince1970 < second.createdAt!.timeIntervalSince1970
                }
                
                self.tableView.reloadData()
            } else {
                fatalError(error!.localizedDescription)
            }
        }
    }
    
    private func orderAtIndexPath(indexPath: NSIndexPath) -> Order {
        return ordersForTicket(tickets[indexPath.section])[indexPath.row]
    }
    
    private func ordersForTicket(ticket: Ticket) -> [Order] {
        return orders.filter { (order: Order) -> Bool in
            return order.ticket.objectId! == ticket.objectId!
        }
    }
    
    // MARK: - UIViewController
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadOrders()
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tickets.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        let order = orderAtIndexPath(indexPath)
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .CurrencyStyle
        let price = numberFormatter.stringFromNumber(NSNumber(double: order.menuItem.price))
        cell.textLabel!.text = "\(order.menuItem.name) [$\(price)]"
        if order.seat == 0 {
            cell.detailTextLabel!.text = order.notes
        } else {
            cell.detailTextLabel!.text = "Seat \(order.seat) – \(order.notes)"
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ordersForTicket(tickets[section]).count
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let ticket = tickets[section]
        
        let ticketHeaderView = TicketHeaderView()
        
        ticketHeaderView.textLabel.text = "Ticket \(ticket.objectId!)"
        
        let subtotal = ordersForTicket(ticket).map { $0.menuItem.price }.reduce(0, combine: +)
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .CurrencyStyle
        let subtotalString = numberFormatter.stringFromNumber(NSNumber(double: subtotal))
        ticketHeaderView.detailLabel.text = "Subtotal: $\(subtotalString)"
        
        // TODO: Give the payButton a title
        
        return ticketHeaderView
    }
    
    // MARK: - UITableViewDelegate

}
