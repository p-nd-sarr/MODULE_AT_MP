$(document).ready ->
  $("#arret_travail_est_journalier").change ->
    $(".salaire-journalier-section").toggle()
  
  $('#arret_travail_declarant').change ->
    event.preventDefault();
    declarant = $('#arret_travail_declarant :selected').text();
    if (declarant == "lui_meme")
      $('.declarant-section').hide();
    else
      $('.declarant-section').show();
