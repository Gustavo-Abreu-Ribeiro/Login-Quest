event_inherited();

// Lógica de Scroll da lista
if (is_top_window) {
    if (mouse_wheel_up()) db_scroll_y -= 25;
    if (mouse_wheel_down()) db_scroll_y += 25;
    
    db_scroll_y = clamp(db_scroll_y, 0, db_max_scroll);
}