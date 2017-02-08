$(document).ready(function() {

  var navLink = $('.o-mast__nav-link--with-submenu');
  var backButton = $('.o-mast__menu-icon__back');
  var closeButton = $('.o-mast__menu-icon__cross');
  var menuButton = $('.o-mast__menu-icon__hamburger');
  var menuToggler = $('#o-mast__menu-toggler-checkbox');
  var itemDetails = $('.o-mast__item-details');
  var mobileRow = $('.o-mast__item--mobile-row');
  var submenu = false;

  menuButton.show();

  navLink.on('click', function(e) {
    var windowWidth = $(window).width();
    if (windowWidth < 480) {
      e.preventDefault();
      var itemDetails = $(e.target).next();
      navLink.hide();
      mobileRow.hide();
      closeButton.hide();
      backButton.show();
      itemDetails.css({
        'display': 'flex',
        'flex-direction': 'column',
      });
      submenu = itemDetails;
    }
  });

  navLink.find('a').on('click', function(e) {
    menuToggler.prop('checked', true);
  });

  backButton.on('click', function(e) {
    var windowWidth = $(window).width();
    if (windowWidth < 480) {
      e.preventDefault();
      navLink.show();
      mobileRow.show();
      closeButton.show();
      backButton.hide();
      itemDetails.hide();
      menuToggler.prop('checked', true);
      submenu = false;
    }
  });

  menuToggler.on('click', function(e) {
    var windowWidth = $(window).width();
    var isChecked = e.target.checked;
    if (windowWidth < 480) {
      if (isChecked === true) {
        menuButton.hide();
        closeButton.show();
      } else {
        menuButton.show();
        closeButton.hide();
      }
    }
  });

  $(window).on('resize', function(e) {
    var windowWidth = $(window).width();
    if (menuToggler.prop('checked') === true) {
      if (submenu) {
        if (windowWidth > 480) {
          navLink.show();
          itemDetails.show();
        } else {
          navLink.hide();
          submenu.css({
            'display': 'flex',
            'flex-direction': 'column',
          });
        }
      } else {
        navLink.show();
        if (windowWidth > 480) {
          itemDetails.show();
          mobileRow.hide();
        } else {
          itemDetails.hide();
          mobileRow.show();
        }
      }
    }
  });
});
