// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function moveEvent(event, dayDelta, minuteDelta, allDay){
  jQuery.ajax({
      data: 'id=' + event.id + '&title=' + event.title + '&day_delta=' + dayDelta + '&minute_delta=' + minuteDelta + '&all_day=' + allDay,
      dataType: 'script',
      type: 'post',
      url: "/<%= view_name %>/move"
  });
}

function resizeEvent(event, dayDelta, minuteDelta){
  jQuery.ajax({
      data: 'id=' + event.id + '&title=' + event.title + '&day_delta=' + dayDelta + '&minute_delta=' + minuteDelta,
      dataType: 'script',
      type: 'post',
      url: "/<%= view_name %>/resize"
  });
}

function showEventDetails(event){
  jQuery('#event_desc').html(event.description);
  jQuery('#edit_event').html("<a href = 'javascript:void(0);' onclick ='editEvent(" + event.id + ")'>Edit</a>");
  if (event.recurring) {
      title = event.title + "(Recurring)";
      jQuery('#delete_event').html("&nbsp; <a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", " + false + ")'>Delete Only This Occurrence</a>");
      jQuery('#delete_event').append("&nbsp;&nbsp; <a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", " + true + ")'>Delete All In Series</a>")
      jQuery('#delete_event').append("&nbsp;&nbsp; <a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", \"future\")'>Delete All Future Events</a>")
  }
  else {
      title = event.title;
      jQuery('#delete_event').html("<a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", " + false + ")'>Delete</a>");
  }
  jQuery('#desc_dialog').dialog({
      title: title,
      modal: true,
      width: 500,
      close: function(event, ui){
          jQuery('#desc_dialog').dialog('destroy')
      }
      
  });
}


function editEvent(event_id){
  jQuery.ajax({
      //data: 'id=' + event_id,
      dataType: 'script',
      type: 'get',
      url: "/<%= view_name %>/" + event_id + "/edit"
  });
}

function deleteEvent(event_id, delete_all){
  jQuery.ajax({
      data: '_method=DELETE',
      dataType: 'script',
      type: 'POST',
      url: "/<%= view_name %>/" + event_id
  });
}

function showPeriodAndFrequency(value){
  switch (value) {
      case 'Daily':
          jQuery('#period').html('day');
          jQuery('#frequency').show();
          break;
      case 'Weekly':
          jQuery('#period').html('week');
          jQuery('#frequency').show();
          break;
      case 'Monthly':
          jQuery('#period').html('month');
          jQuery('#frequency').show();
          break;
      case 'Yearly':
          jQuery('#period').html('year');
          jQuery('#frequency').show();
          break;
          
      default:
          jQuery('#frequency').hide();
  }    
}
