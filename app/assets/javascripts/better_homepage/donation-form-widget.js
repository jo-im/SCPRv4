var donationForm = document.getElementById('springboard');
var url = 'https://support.kpcc.org/f19hptakeover2';

var toggleForm = function(donationType) {
  var monthlyDonationFields = document.getElementById('springboard__monthly-donation-fields');
  var oneTimeDonationFields = document.getElementById('springboard__one-time-donation-fields');

  if (donationType === 'monthly') {
    monthlyDonationFields.style.display = 'flex';
    oneTimeDonationFields.style.display = 'none';
  } else if (donationType === 'one-time') {
    monthlyDonationFields.style.display = 'none';
    oneTimeDonationFields.style.display = 'flex';
  }
}

var searchForCheckedDonation = function(recurs, purpose) {
  var donations = [];
  var linkElement = document.getElementById('springboard__continue');

  if (recurs === 'monthly') {
    var fivePerMonth = donationForm[2];
    var tenPerMonth = donationForm[3];
    var fifteenPerMonth = donationForm[4];
    var oneTwentyFivePerMonth = donationForm[5];

    donations = [fivePerMonth, tenPerMonth, fifteenPerMonth, oneTwentyFivePerMonth];
  } else if (recurs === 'one-time') {
    var oneTime60 = donationForm[7];
    var oneTime120 = donationForm[8];
    var oneTime180 = donationForm[9];
    var oneTime1600 = donationForm[10]

    donations = [oneTime60, oneTime120, oneTime180, oneTime1600];
  }

  donations.forEach(function(donation) {
    if (donation.checked) {
      var amount = donation.value;

      if (purpose === 'sendCheckedDonation') {
        var destinationUrl = url + '?amount=' + amount + '&recurs=' + recurs;
        linkElement.href = destinationUrl;
      } else if (purpose === 'uncheckDonation') {
        donation.checked = false;
      }
    }
  });
}

donationForm.onclick = function(e) {
  var id = e.target.id;
  var className = e.target.classList[0];

  // Toggle between tabs
  if (id === 'springboard__monthly-donation') {
    toggleForm('monthly');
  } else if (id === 'springboard__one-time-donation') {
    toggleForm('one-time');
  }

  // Uncheck all radios if other amount input box is clicked
  if (id === 'springboard__per-month-other-amount') {
    searchForCheckedDonation('monthly', 'uncheckDonation');
  } else if (id === 'springboard__one-time-other-amount') {
    searchForCheckedDonation('one-time', 'uncheckDonation');
  }

  // If a donation button is clicked, clear out the input box
  if (className === 'springboard__per-month') {
    var perMonthOtherAmount = document.getElementById('springboard__per-month-other-amount');
    perMonthOtherAmount.value = '';
  } else if (className === 'springboard__one-time') {
    var oneTimeOtherAmount = document.getElementById('springboard__one-time-other-amount');
    oneTimeOtherAmount.value = '';
  }
}

donationForm.onchange = function(e) {
  e.preventDefault();

  var form = e.srcElement.form;
  var monthlyDonation = form[0];
  var oneTimeDonation = form[1];
  var linkElement = document.getElementById('springboard__continue');
  var recurs, otherAmount;

  if (monthlyDonation.checked) {
    recurs = 'monthly';
    otherAmount = form[6].value;
  } else if (oneTimeDonation.checked) {
    recurs = 'one-time';
    otherAmount = form[11].value;
  }

  if (otherAmount) {
    var destinationUrl = url + '?amount=' + otherAmount + '&recurs=' + recurs;
    linkElement.href = destinationUrl;
  } else {
    searchForCheckedDonation(recurs, 'sendCheckedDonation');
  }
}
