function convertToHumanDate(date){
  arDate = date.split("-");
  return arDate.reverse().join('.');
}

function convertToHumanDateTime(dateTime){
  date = dateTime.split("T")[0];
  time = dateTime.split("T")[1].split("+")[0].split(":");
  time.pop();
  console.log(time)
  return convertToHumanDate(date) + " " + time.join(":");
}
