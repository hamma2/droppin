extends Node

# A signal to notify the UI when the inventory changes.
signal inventory_changed

var items: Array[CollectibleExtrasEffects] = []

func add_item(item: CollectibleExtrasEffects) -> bool:
    var slot = first_free_slot()
    if slot == -1:
        return false

    item.slot_index = slot
    items.append(item)
    inventory_changed.emit()
    return true

func remove_item(item: CollectibleExtrasEffects):
    if items.has(item):
        items.erase(item)
        inventory_changed.emit()

func remove_all_items():
    items.clear()
    inventory_changed.emit()

func item_in_slot(slot: int) -> CollectibleExtrasEffects:
    for item in items:
        if item.slot_index == slot:
            return item
    return null

func first_free_slot() -> int:
    for slot in Settings.inventoryKeys.size():
        if item_in_slot(slot) == null:
            return slot
    return -1

func activate_item(keycode: Key) -> bool:
    for item in items:
        if Settings.inventoryKeys[item.slot_index] == keycode:
            item.activate()
            return true
    return false

func notify_keys_changed():
    inventory_changed.emit()
