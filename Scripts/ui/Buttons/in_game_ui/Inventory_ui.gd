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
    var inventory_items = Inventory.items

    for i in range(slots.size()):
        var slot = slots[i]
        if i < inventory_items.size():
            # If there's an item for this slot, display it.
            var item = inventory_items[i]
            slot.get_node("TextureRect").texture = item.extra_data.texture
            # (Add logic for label/quantity here)
        else:
            # Otherwise, clear the slot.
            slot.get_node("TextureRect").texture = null
