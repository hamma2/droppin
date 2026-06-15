extends Node

# A signal to notify the UI when the inventory changes.
signal inventory_changed

var items: Array[ExtraItem] = []

func add_item(item: ExtraItem):
    items.append(item)
    inventory_changed.emit()

func remove_item(item: ExtraItem):
    if items.has(item):
        items.erase(item)
        inventory_changed.emit()