extends Node

# A signal to notify the UI when the inventory changes.
signal inventory_changed

var items: Array[CollectibleExtrasEffects] = []

func add_item(item: CollectibleExtrasEffects):
    items.append(item)
    inventory_changed.emit()

func remove_item(item: CollectibleExtrasEffects):
    if items.has(item):
        items.erase(item)
        inventory_changed.emit()

func remove_all_items():
    items.clear()
    inventory_changed.emit()
