//= require local_storage_manager

$(document).ready(function () {
    var url_path_name = split_url(window.location.pathname, 3);
    var tab_link_array = Array.from(document.getElementsByClassName('tab-link-top'));
    var tab_content_array = Array.from(document.getElementsByClassName('tab-pane-section'));
    var current_tab = 'current-tab'
    var current_pathname = 'current-path'

    function set_url(url) {
        if (get_item(current_pathname) !== url) {
            localStorage.setItem(current_pathname, url);
            clearStorage(current_tab);
        }
    }

    function add_active_class() {
        let index = get_item(current_tab) || 0;
        index = Math.min(index, tab_link_array.length - 1); // S'assurer que l'index ne dépasse pas la taille des tableaux

        if (tab_link_array[index]) {
            tab_link_array[index].classList.add('active');
            tab_content_array[index].classList.add('active');
        }
    }

    for (let i = 0; i < tab_link_array.length; i++) {
        tab_link_array[i].addEventListener('click', function (event) {
            set_item(current_tab, i)
        });
    }

    function split_url(url, n) {
        return url.split('/').slice(0, n).join('/');
    }

    set_url(url_path_name);
    add_active_class();

});