function delete_answer(node)
{
  return node.parentNode.parentNode.parentNode.parentNode.removeChild(node.parentNode.parentNode.parentNode);
}

function another_answer()
{
  /* <div class="answer_options">
        <label for="answer_is_correct">Is correct</label>
        <input id="answer_14_is_correct" 
	  name="answer[14][is_correct]" 
	  value="1" type="checkbox">
	<input name="answer[14][is_correct]" 
	   value="0" type="hidden">
  */
  var randomnumber= 'new' + Math.floor(Math.random()*101);
  answer = document.createElement('div');
  answer.setAttribute('class','answer');
  
  answer_header = document.createElement('div');
  answer_header.setAttribute('class', 'answer_header');
  answer.appendChild(answer_header);
  
  answer_number = document.createElement('div');
  answer_number.setAttribute('class', 'answer_number');
  answer_header.appendChild(answer_number);
  
  content_label = document.createElement('label');
  content_label.setAttribute('for', 'answer_' + randomnumber + '_content');
  content_label.appendChild(document.createTextNode('Answer ' + randomnumber));
  answer_number.appendChild(content_label);

  answer_options = document.createElement('div');
  answer_options.setAttribute('class', 'answer_options');
  answer_header.appendChild(answer_options);

  is_correct_label = document.createElement('label');
  is_correct_label.setAttribute('for', 'answer_' + randomnumber + '_is_correct');
  is_correct_label.appendChild(document.createTextNode("Is correct"));
  answer_options.appendChild(is_correct_label);
  
  cb = document.createElement('input');
  cb.setAttribute('type', 'checkbox');
  cb.setAttribute('id', 'answer_' + randomnumber + '_is_correct');
  cb.setAttribute('name', 'answer[' + randomnumber + '][is_correct]');
  cb.setAttribute('value', "1");
  answer_options.appendChild(cb);
  
  cbd = document.createElement('input');
  cbd.setAttribute('name', 'answer[' + randomnumber + '][is_correct]');
  cbd.setAttribute('type', 'hidden' );
  cbd.setAttribute('value', "0");
  answer_options.appendChild(cbd);
  
  del = document.createElement('a');
  del.setAttribute( 'onclick', 'delete_answer(this); return false');
  del.setAttribute('href', '#');
  del.appendChild(document.createTextNode("delete"));
  answer_options.appendChild(del);
  
  answer_content = document.createElement('div');
  answer_content.setAttribute('class', 'answer_content');
  answer.appendChild(answer_content);
  
  content = document.createElement('textarea');
  content.setAttribute('class', 'answer_content' );
  content.setAttribute('id', 'answer_' + randomnumber + '_content' );
  content.setAttribute('name', 'answer[' + randomnumber + '][content]');
  content.setAttribute('cols', 40 );
  content.setAttribute('rows', 20 );
  answer_content.appendChild(content);
  
  document.getElementById("allanswers").appendChild(answer);
}
