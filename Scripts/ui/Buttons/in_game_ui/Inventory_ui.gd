# InventoryUI.gd
extends Panel

@onready var grid_container = $InventoryUI

func _ready():
    # Connect to the inventory's signal.
    # Now, whenever an item is added or removed, update_ui() is called.
    Inventory.inventory_changed.connect(update_ui)

    # Initial UI update.
    update_ui()

func update_ui():
    var slots = grid_container.get_children()

    for i in range(slots.size()):
        var slot = slots[i]
        var item = Inventory.item_in_slot(i)
        if item != null:
            # If there's an item for this slot, display it.
            slot.get_node("TextureRect").texture = item.texture
            # (Add logic for label/quantity here)
        else:
            # Otherwise, clear the slot.
            slot.get_node("TextureRect").texture = null

        if i < Settings.inventoryKeys.size():
            slot.get_node("TextureRect/Label").text = OS.get_keycode_string(Settings.inventoryKeys[i])
