
function set_item(item_name, obj) {
    localStorage.setItem(item_name, obj);
}

function get_item(item_name) {
    return localStorage.getItem(item_name);
}

function clearStorage(item_name) {
    if (localStorage.getItem(item_name) != null) {
        localStorage.removeItem(item_name)
    }
}