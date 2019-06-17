/*

Theme: Purpose - Website UI Kit
Product Page: https://themes.getbootstrap.com/product/purpose-website-ui-kit/
Author: Webpixels
Author URI: https://www.webpixels.io

---

Copyright 2018-2019 Webpixels

*/

//
// Layout
//

'use strict';

var Layout = (function() {

    function pinSidenav($this) {
        $('.sidenav-toggler').addClass('active');
        $('.sidenav-toggler').data('action', 'sidenav-unpin');
        $('body').addClass('sidenav-pinned ready');
        $('body').find('.main-content').append('<div class="sidenav-mask mask-body d-xl-none" data-action="sidenav-unpin" data-target='+$this.data('target')+' />');

        var $sidenav = $($this.data('target'));

        $sidenav.addClass('show');

        // Store the sidenav state in a cookie session
        localStorage.setItem('sidenav-state', 'pinned');

        // alert('pinned')
    }

    function unpinSidenav($this) {
        $('.sidenav-toggler').removeClass('active');
        $('.sidenav-toggler').data('action', 'sidenav-pin');
        $('body').removeClass('sidenav-pinned');
        $('body').addClass('ready')
        $('body').find('.sidenav-mask').remove();

        var $sidenav = $($this.data('target'));

        $sidenav.removeClass('show');

        // Store the sidenav state in a cookie session
        localStorage.setItem('sidenav-state', 'unpinned');

        // alert('unpinned')
    }

    // Set sidenav state from cookie

    var $sidenavState = localStorage.getItem('sidenav-state') ? localStorage.getItem('sidenav-state') : 'pinned';

	$(window).on({
		'load resize': function() {
            if($(window).width() < 1200) {

                    unpinSidenav($('.sidenav-toggler'));

            } else {
                if($sidenavState == 'pinned') {
                    pinSidenav($('.sidenav-toggler'));
                }
                else if($sidenavState == 'unpinned') {
                    unpinSidenav($('.sidenav-toggler'));
                }
            }
		}
	})



    $("body").on("click", "[data-action]", function(e) {

        e.preventDefault();

        var $this = $(this);
        var action = $this.data('action');
        var target = $this.data('target');

        switch (action) {
            case "offcanvas-open":
                target = $this.data("target"), $(target).addClass("open"), $("body").append('<div class="body-backdrop" data-action="offcanvas-close" data-target=' + target + " />");
                break;

            case "offcanvas-close":
                target = $this.data("target"), $(target).removeClass("open"), $("body").find(".body-backdrop").remove();
                break;

            case 'aside-open':
                target = $this.data('target');
                $this.addClass('active');
                $(target).addClass('show');
                $('body').append('<div class="mask-body mask-body-light" data-action="aside-close" data-target='+target+' />');
                break;

            case 'aside-close':
                target = $this.data('target');
                $this.removeClass('active');
                $(target).removeClass('show');
                $('body').find('.body-backdrop').remove();
                break;

            case 'omnisearch-open':
                target = $this.data('target');
                $this.addClass('active');
                $(target).addClass('show');
                $(target).find('.form-control').focus();
                $('body').addClass('omnisearch-open').append('<div class="mask-body mask-body-dark" data-action="omnisearch-close" data-target="'+target+'" />');
                break;

            case 'omnisearch-close':
                target = $this.data('target');
                $('[data-action="search-open"]').removeClass('active');
                $(target).removeClass('show');
                $('body').removeClass('omnisearch-open').find('.mask-body').remove();
                break;

            case 'search-open':
                target = $this.data('target');
                $this.addClass('active');
                $(target).addClass('show');
                $(target).find('.form-control').focus();
                break;

            case 'search-close':
                target = $this.data('target');
                $('[data-action="search-open"]').removeClass('active');
                $(target).removeClass('show');
                break;

            case 'sidenav-pin':
                pinSidenav($this);
                break;

            case 'sidenav-unpin':
                unpinSidenav($this);
                break;
        }
    })

    // Add sidenav modifier classes on mouse events

    // $('.sidenav').on('mouseenter', function() {
    //     if(! $('body').hasClass('g-sidenav-pinned')) {
    //         $('body').removeClass('g-sidenav-hide').removeClass('g-sidenav-hidden').addClass('g-sidenav-show');
    //     }
    // })
    //
    // $('.sidenav').on('mouseleave', function() {
    //     if(! $('body').hasClass('g-sidenav-pinned')) {
    //         $('body').removeClass('g-sidenav-show').addClass('g-sidenav-hide');
    //
    //         setTimeout(function() {
    //             $('body').removeClass('g-sidenav-hide').addClass('g-sidenav-hidden');
    //         }, 300);
    //     }
    // })

    // Offset an element by giving an existing element's class or id from the same page

    if($('[data-offset-top]').length) {
        var $el = $('[data-offset-top]'),
            $offsetEl = $($el.data('offset-top')),
            offset = $offsetEl.height();


        $el.css({'padding-top':offset+'px'})
    }
})();

//
// Popover
//

'use strict';

var Popover = (function() {

	// Variables

	var $popover = $('[data-toggle="popover"]');


	// Methods

	function init($this) {
		var popoverClass = '';

		if ($this.data('color')) {
			popoverClass = ' popover-' + $this.data('color');
		}

		var options = {
			trigger: 'focus',
			template: '<div class="popover' + popoverClass + '" role="tooltip"><div class="arrow"></div><h3 class="popover-header"></h3><div class="popover-body"></div></div>'
		};

		$this.popover(options);
	}


	// Events

	if ($popover.length) {
		$popover.each(function() {
			init($(this));
		});
	}

})();

//
// Style
// Style helper function to get colors and more
//

var PurposeStyle = (function() {

	// Variables

	var style = getComputedStyle(document.body);
    var colors = {
    		gray: {
    			100: '#f6f9fc',
    			200: '#e9ecef',
    			300: '#dee2e6',
    			400: '#ced4da',
    			500: '#adb5bd',
    			600: '#8898aa',
    			700: '#525f7f',
    			800: '#32325d',
    			900: '#212529'
    		},
    		theme: {
    			'primary': style.getPropertyValue('--primary') ? style.getPropertyValue('--primary').replace(' ', '') : '#6e00ff',
    			'info': style.getPropertyValue('--info') ? style.getPropertyValue('--info').replace(' ', '') : '#00B8D9',
    			'success': style.getPropertyValue('--success') ? style.getPropertyValue('--success').replace(' ', '') : '#36B37E',
    			'danger': style.getPropertyValue('--danger') ? style.getPropertyValue('--danger').replace(' ', '') : '#FF5630',
    			'warning': style.getPropertyValue('--warning') ? style.getPropertyValue('--warning').replace(' ', '') : '#FFAB00',
                'dark': style.getPropertyValue('--dark') ? style.getPropertyValue('--dark').replace(' ', '') : '#212529'
    		},
    		transparent: 'transparent',
    	},
		fonts = {
			base: 'Nunito'
		}

	// Return

	return {
		colors: colors,
		fonts: fonts
	};

})();

//
// Tooltip
//

'use strict';

var Tooltip = (function() {

	// Variables

	var $tooltip = $('[data-toggle="tooltip"]');


	// Methods

	function init() {
		$tooltip.tooltip();
	}


	// Events

	if ($tooltip.length) {
		init();
	}

})();

//
// Background image holder
//

'use strict';

var BgImgHolder = (function() {

	// Variables

	var $bgImgHolder = $(".bg-img-holder");


	// Methods

	function init($this) {
		var img = $this.children("img").attr("src"),
            position = $this.data('bg-position') ? $this.data('bg-position') : 'initial',
            size = $this.data('bg-size') ? $this.data('bg-size') : 'auto',
            height = $this.data('bg-height') ? $this.data('bg-height') : '100%';

		$this
	        .css("background-image", 'url("'+img+'")')
	        .css("background-position", position)
	        .css("background-size", size)
	        .css("opacity", "1")
	        .css("height", height);
	}


	// Events

	if ($bgImgHolder.length) {
		$bgImgHolder.each(function() {
			init($(this));
		})
	}

})();

//
// Card
//

'use strict';

// Card actions

var CardActions = (function() {

	// Variables

	var $card = $(".card"),
		actions = '.card-product-actions';


	// Methods

	function show($this) {
		var $el = $this.find(actions),
        	animation = $el.data('animation-in');

        if ($el.length) {
            $el.addClass('in animated ' + animation);
            $el.one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function() {
                $el.removeClass('animated ' + animation);
            });
		}
	}

	function hide($this) {
		var $el = $this.find(actions),
			animation = $el.data('animation-out');

		if ($el.length) {
			$el.addClass('animated ' + animation);
			$el.one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function() {
				$el.removeClass('in animated ' + animation);
			});
		}
	}

	// Events

	if ($card.length && $(actions).length) {
		$card.on({
    		'mouseenter': function() {
    			show($(this));
    		}
    	})

		$card.on({
    		'mouseleave': function() {
    			hide($(this));
    		}
    	})
	}

})();

// //
// // Customizer
// //
//
// 'use strict';
//
// var Customizer = (function() {
//
// 	//
// 	// Variables
// 	//
//
// 	// Selectors
// 	var form = document.querySelector('#form-customizer');
// 	var navbar = document.querySelector('#navbar-main');
// 	var navbarLogo = document.querySelector('#navbar-logo');
// 	var topbar = document.querySelector('#navbar-top-main');
// 	var sidebar = document.querySelector('#sidenav-main');
// 	var stylesheet = document.getElementById('stylesheet');
//
// 	// Config
// 	var config = {
// 		skin: (localStorage.getItem('purposeSkin')) ? localStorage.getItem('purposeSkin') : 'default',
// 		mode: (localStorage.getItem('purposeMode')) ? localStorage.getItem('purposeMode') : 'light',
// 	}
//
// 	//
// 	// Methods
// 	//
//
// 	function parseUrl() {
// 		var search = window.location.search.substring(1);
// 		var params = search.split('&');
//
// 		for (var i = 0; i < params.length; i++) {
// 			var arr = params[i].split('=');
// 			var prop = arr[0];
// 			var val = arr[1];
//
// 			if (prop == 'skin' || prop == 'mode') {
//
// 				// Save to localStorage
// 				localStorage.setItem('purpose' + prop.charAt(0).toUpperCase() + prop.slice(1), val);
//
// 				// Update local variables
// 				config[prop] = val;
// 			}
// 		}
// 	}
//
//
// 	function toggleSkin(skin, mode, callback) {
// 		if (stylesheet) {
// 			var params = stylesheet.getAttribute("href").split('/');
//
// 			var file = params[params.length - 1];
// 			var newFile;
//
// 			if (skin == 'default' && mode == 'light') {
// 				newFile = 'purpose.css';
// 			} else if (skin == 'default' && mode == 'dark') {
// 				newFile = 'purpose-dark.css';
// 			} else {
// 				newFile = 'purpose-' + skin + '-' + mode + '.css';
// 			}
//
// 			newFile = stylesheet.getAttribute('href').replace(file, newFile);
//
// 			stylesheet.setAttribute('href', newFile);
//
// 			if (callback) {
// 				callback();
// 			}
// 		}
// 	}
//
// 	function toggleNavbarColor(mode) {
// 		if (mode == 'dark') {
// 			if (navbar) {
// 				navbar.classList.remove('navbar-light', 'bg-white');
// 				navbar.classList.add('navbar-dark', 'bg-dark');
// 			}
// 			if (topbar) {
// 				topbar.classList.remove('navbar-light', 'bg-white');
// 				topbar.classList.add('navbar-dark', 'bg-dark');
// 			}
//
// 			if (sidebar) {
// 				sidebar.classList.remove('navbar-light', 'bg-white');
// 				sidebar.classList.add('navbar-dark', 'bg-dark');
// 			}
// 		}
// 	}
//
// 	function toggleLogo(mode) {
// 		if (navbarLogo) {
// 			var params = navbarLogo.getAttribute("src").split('/');
//
// 			var file = params[params.length - 1];
// 			var newFile;
//
// 			if (mode == 'dark') {
// 				newFile = 'white.png';
// 				newFile = navbarLogo.getAttribute('src').replace(file, newFile);
//
// 				navbarLogo.setAttribute('src', newFile);
// 			}
// 		}
// 	}
//
// 	function toggleFormControls(form, skin, mode) {
// 		$(form).find('[name="skin"][value="' + skin + '"]').closest('.btn').button('toggle');
// 		$(form).find('[name="mode"][value="' + mode + '"]').closest('.btn').button('toggle');
// 	}
//
// 	function submitForm(form) {
// 		var skin = form.querySelector('[name="skin"]:checked').value;
// 		var mode = form.querySelector('[name="mode"]:checked').value;
//
// 		// Save data to localStorage
// 		localStorage.setItem('purposeSkin', skin);
// 		localStorage.setItem('purposeMode', mode);
//
// 		// Reload page
// 		window.location = window.location.pathname;
// 	}
//
//
// 	//
// 	// Event
// 	//
//
// 	// Parse url
// 	parseUrl();
//
// 	// Toggle skin
// 	if(stylesheet) {
// 		document.body.style.opacity = '0';
// 		window.addEventListener('load', function() {
// 			toggleSkin(config.skin, config.mode, function() {
// 				// alert('CSS file loaded!');
// 				document.body.style.opacity = '1';
// 			});
// 		});
// 	}
//
// 	toggleNavbarColor(config.mode);
// 	toggleLogo(config.mode);
//
// 	// Toggle form controls
// 	toggleFormControls(form, config.skin, config.mode);
//
// 	// Form submitted
// 	if (form) {
// 		form.addEventListener('submit', function(e) {
// 			e.preventDefault();
//
// 			// Apply changes
// 			submitForm(form);
// 		});
// 	}
//
// })();

//
// Dropdown
//

'use strict';

var Dropdown = (function() {

	// Variables

	var $dropdown = $('.dropdown-animate'),
		$dropdownSubmenu = $('.dropdown-submenu [data-toggle="dropdown"]');


	// Methods

	function hideDropdown($this) {

		// Add additional .hide class for animated dropdown menus in order to apply some css behind

		// var $dropdownMenu = $this.find('.dropdown-menu');
		//
        // $dropdownMenu.addClass('hide');
		//
        // setTimeout(function(){
        //     $dropdownMenu.removeClass('hide');
        // }, 300);

	}

	function initSubmenu($this) {
        if (!$this.next().hasClass('show')) {
            $this.parents('.dropdown-menu').first().find('.show').removeClass("show");
        }

        var $submenu = $this.next(".dropdown-menu");

        $submenu.toggleClass('show');
        $submenu.parent().toggleClass('show');

        $this.parents('.nav-item.dropdown.show').on('hidden.bs.dropdown', function(e) {
            $('.dropdown-submenu .show').removeClass("show");
        });
	}

	// Events

	if ($dropdown.length) {
    	$dropdown.on({
    		'hide.bs.dropdown': function() {
    			hideDropdown($dropdown);
    		}
    	})
	}

	if ($dropdownSubmenu.length) {
		$dropdownSubmenu.on('click', function(e) {

			initSubmenu($(this))

			return false;
		});
	}
})();

//
// Forms
//

'use strict';


//
// Form control
//

var FormControl = (function() {

	// Variables

	var $input = $('.form-control'),
		$indeterminateCheckbox = $('[data-toggle="indeterminate"]');


	// Methods

	function init($this) {
		$this.on('focus blur', function(e) {
        	$(this).parents('.form-group').toggleClass('focused', (e.type === 'focus'));
    	}).trigger('blur');
	}


	// Events

	if ($input.length) {
		init($input);
	}

	// Add indeterminate state to a checkbox
	if($indeterminateCheckbox.length) {
		$indeterminateCheckbox.each(function() {
			$(this).prop('indeterminate', true)
		})
	}

})();


//
// Custom input file
//

var CustomInputFile = (function() {

	// Variables

	var $customInputFile = $('.custom-input-file');


	// Methods

	function change($input, $this, $e) {
		var fileName,
			$label = $input.next('label'),
			labelVal = $label.html();

		if ($this && $this.files.length > 1) {
			fileName = ($this.getAttribute('data-multiple-caption') || '').replace('{count}', $this.files.length);
		}
		else if ($e.target.value) {
			fileName = $e.target.value.split('\\').pop();
		}

		if (fileName) {
			$label.find('span').html(fileName);
		}
		else {
			$label.html(labelVal);
		}
	}

	function focus($input) {
		$input.addClass('has-focus');
	}

	function blur($input) {
		$input.removeClass('has-focus');
	}


	// Events

	if ($customInputFile.length) {
		$customInputFile.each(function() {
			var $input = $(this);

			$input.on('change', function(e) {
				var $this = this,
					$e = e;

				change($input, $this, $e);
	        });

	        // Firefox bug fix
	        $input.on('focus', function() {
	            focus($input);
	        })
	        .on('blur', function() {
	            blur($input);
	        });
		});
	}
})();

//
// Navbar
//

'use strict';

var NavbarVertical = (function() {

	// Variables

    var $nav = $('.navbar-vertical .navbar-nav, .navbar-vertical .navbar-nav .nav');
	var $collapse = $('.navbar-vertical .collapse');
    var $dropdown = $('.navbar-vertical .dropdown');

	// Methods

	function accordion($this) {
		$this.closest($nav).find($collapse).not($this).collapse('hide');
	}

    function closeDropdown($this) {
        var $dropdownMenu = $this.find('.dropdown-menu');

        $dropdownMenu.addClass('close');

    	setTimeout(function() {
    		$dropdownMenu.removeClass('close');
    	}, 200);
	}


	// Events

	$collapse.on({
		'show.bs.collapse': function() {
			accordion($(this));
		}
	})

	$dropdown.on({
		'hide.bs.dropdown': function() {
			closeDropdown($(this));
		}
	})

})();

var NavbarCollapse = (function() {

	// Variables

    var $nav = $('#navbar-main'),
	    $collapse = $('#navbar-main-collapse'),
        $navTop = $('#navbar-top-main');


	// Methods

	function showNavbarCollapse($this) {
        $nav.addClass('navbar-collapsed');
        $navTop.addClass('navbar-collapsed');
        $('#header-main').addClass('header-collapse-show');
        $('body').addClass('modal-open');
	}

    function hideNavbarCollapse($this) {
        $this.removeClass('collapsing').addClass('collapsing-out');
        $nav.removeClass('navbar-collapsed').addClass('navbar-collapsed-out');
        $navTop.removeClass('navbar-collapsed').addClass('navbar-collapsed-out');
	}

    function hiddenNavbarCollapse($this) {
        $this.removeClass('collapsing-out');
        $nav.removeClass('navbar-collapsed-out');
        $navTop.removeClass('navbar-collapsed-out');
        $('#header-main').removeClass('header-collapse-show');
        $('body').removeClass('modal-open');
	}


	// Events

    if ($collapse.length) {
    	$collapse.on({
    		'show.bs.collapse': function() {
    			showNavbarCollapse($collapse);
    		}
    	})

        $collapse.on({
    		'hide.bs.collapse': function() {
                hideNavbarCollapse($collapse);
    		}
    	})

        $collapse.on({
    		'hidden.bs.collapse': function() {
                hiddenNavbarCollapse($collapse);
    		}
    	})
    }

})();


//
// Sticky Navbar
//

var NavbarSticky = (function() {

	// Variables

	var $nav = $('.navbar-sticky');


	// Methods

	function init($this) {

		var scrollTop = $(window).scrollTop(); // our current vertical position from the top

		// if we've scrolled more than the navigation, change its position to fixed to stick to top,
		// otherwise change it back to relative
		if (scrollTop > (navOffsetTop + 200)) {
			$this.addClass('sticky');
		} else {
			$this.removeClass('sticky');
		}
	}


	// Events

	if ($nav.length) {

        var navOffsetTop = $nav.offset().top;

		// Init sticky navbar
		init($nav);

		// re-calculate stickyness on scroll
		$(window).on({
			'scroll': function() {
				init($nav);
			}
		})
	}
})();

//
// Negative margin
//

'use strict';

var NegativeMargin = (function() {

	// Variables

	var $item = $('[data-negative-margin]');


	// Methods

	function init($this) {
		var $target = $this.find($($this.data('negative-margin'))),
			height = $target.height();

			console.log(height)
        if ($(window).width() > 991) {
            $this.css({'margin-top': '-' + height + 'px'});
        }
        else {
            $this.css({'margin-top': '0'});
        }
	}


	// Events

	$(window).on({
		'load resize': function() {
			if ($item.length) {
				$item.each(function() {
					init($(this));
				});
			}
		}
	})

})();

//
// Toggle password visibility
//

'use strict';

var PasswordText = (function() {

	//
	// Variables
	//

	var $trigger = $('[data-toggle="password-text"]');


	//
	// Methods
	//

	function init($this) {
		var $password = $($this.data('target'));


		$password.attr('type') == 'password' ? $password.attr('type', 'text') : $password.attr('type', 'password');

		return false;
	}


	//
	// Events
	//

	if ($trigger.length) {
		// Init scroll on click
		$trigger.on('click', function(event) {
			init($(this));
		});
	}

})();

//
// Pricing
//

'use strict';


var Pricing = (function() {

	// Variables

	var $pricingContainer = $('.pricing-container'),
		$btn = $('.pricing-container button[data-pricing]');


	// Methods

	function init($this) {
        var a = $this.data('pricing'),
            b = $this.parents('.pricing-container'),
            c = $('.'+b.attr('class')+' [data-pricing-value]');


        if(!$this.hasClass('active')) {
            // Toggle active classes for monthly/yearly buttons
            $('.'+b.attr('class')+' button[data-pricing]').removeClass('active');
            $this.addClass('active');

            // Change price values
            c.each(function() {
                var new_val = $(this).data('pricing-value');
                var old_val = $(this).find('span.price').text();

                $(this).find('span.price').text(new_val);
                $(this).data('pricing-value', old_val);
            });
        }
	}


	// Events

	if ($pricingContainer.length) {
		$btn.on({
    		'click': function() {
    			init($(this));
    		}
    	})
	}

})();

//
// Scroll to (anchor links)
//

'use strict';

var ScrollTo = (function() {

	//
	// Variables
	//

	var $scrollTo = $('.scroll-me, [data-scroll-to], .toc-entry a'),
		urlHash = window.location.hash;


	//
	// Methods
	//

	function init(hash) {
		$('html, body').animate({
	        scrollTop: $(hash).offset().top
	    }, 'slow');
	}

	function scrollTo($this) {
		var $el = $this.attr('href');
        var offset = $this.data('scroll-to-offset') ? $this.data('scroll-to-offset') : 0;
		var options = {
			scrollTop: $($el).offset().top - offset
		};

        // Animate scroll to the selected section
        $('html, body').stop(true, true).animate(options, 300);

        event.preventDefault();
	}


	//
	// Events
	//

	if ($scrollTo.length) {
		// Init scroll on click
		$scrollTo.on('click', function(event) {
			scrollTo($(this));
		});
	}

	$(window).on("load", function () {
		// Init scroll on page load if a hash is present
		if(urlHash && urlHash != '#!' && $(urlHash).length) {
			init(urlHash)
		}
	});
})();

//
// Send email
//

'use strict';


var SendEmail = (function() {

	// Variables

	var $form = $('#form-contact');


	// Methods

	function notify(placement, align, icon, type, animIn, animOut) {
		$.notify({
			icon: icon,
			title: ' Bootstrap Notify',
			message: 'Turning standard Bootstrap alerts into awesome notifications',
			url: ''
		}, {
			element: 'body',
			type: type,
			allow_dismiss: true,
			placement: {
				from: placement,
				align: align
			},
			offset: {
				x: 15, // Keep this as default
				y: 15 // Unless there'll be alignment issues as this value is targeted in CSS
			},
			spacing: 10,
			z_index: 1080,
			delay: 2500,
			timer: 25000,
			url_target: '_blank',
			mouse_over: false,
			animate: {
				// enter: animIn,
				// exit: animOut
                enter: animIn,
                exit: animOut
			},
			template:   '<div class="alert alert-{0} alert-icon alert-group alert-notify" data-notify="container" role="alert">' +
					  		'<div class="alert-group-prepend align-self-start">' +
					  			'<span class="alert-group-icon"><i data-notify="icon"></i></span>' +
					  		'</div>' +
					  		'<div class="alert-content">' +
								'<strong data-notify="title">{1}</strong>' +
								'<div data-notify="message">{2}</div>' +
							'</div>' +
					  		'<button type="button" class="close" data-notify="dismiss" aria-label="Close">' +
								'<span aria-hidden="true">&times;</span>' +
							'</button>' +
						'</div>'

		});
	}

	function init($this, e) {

		var buttonText =  $this.find('button[type="submit"]').text();

		if (e.isDefaultPrevented()) {
			// handle the invalid form...
		} else {
			var formData = $this.serialize();
			console.log(formData);
			var subscribeRequest = $.ajax({
				type: "POST",
				url: $this.data('process'),
				data: formData,
				dataType: 'json'
			});

			// Changing button text
			$this.find('button[type="submit"]').text('Sending...');

			// Get success status and data
			subscribeRequest.done(function(data, msg) {

				var status = data['status'];

				var notifyTitle = data['notify_title'];
				var notifyMessage = data['notify_message'];
				var notifyType = data['notify_type'];

				// Create notification
				notify(notifyTitle, notifyMessage, notifyType);

				if (status == 'success') {
					// Clear form
					$this.find('.btn-reset').trigger('click');
					// $this.find('.glyphicon-ok').removeClass('glyphicon-ok');
					grecaptcha.reset();
				}

				$this.find('button[type="submit"]').text('Message sent!');

				setTimeout(function() {
					$this.find('button[type="submit"]').text(buttonText);
				}, 3000);

			});

			subscribeRequest.fail(function(data, textStatus) {
				var status = data['status'];

				var notifyTitle = data['notify_title'];
				var notifyMessage = data['responseText'];
				var notifyType = 'danger';

				// Create notification
				notify(notifyTitle, notifyMessage, notifyType);

				$this.find('button[type="submit"]').text('Error!');

				setTimeout(function() {
					$this.find('button[type="submit"]').text(buttonText);
				}, 3000);
			});
		}
	}


	// Events

	if ($form.length) {
		$form.on('submit', function(e) {
			init($(this), e);
			return false
		})
	}

})();

//
// Shape
// extending the functionality of the shape utility classes from purpose/utitlies/_shape.scss
//


'use strict';

var Shape = (function() {

	// Variables

	var $shape = $('.shape-container');


	// Methods

	function init($this) {

		var svgHeight = $this.find('svg').height();
		// alert(svgHeight)
		$this.css({
			'height': svgHeight + 'px'
		});

	}


	// Events

	$(window).on({
		'load resize': function() {
			if ($shape.length) {
				$shape.each(function() {
					init($(this));
				});
			}
		}
	})

})();

//
// Spotlight
//

'use strict';

var Spotlight = (function() {

	// Variables

	var $spotlight = $('[data-spotlight]');


	// Methods

	function init($this) {

		var holderHeight,
			animEndEv = "webkitAnimationEnd animationend";

		if ($this.data('spotlight') == 'fullscreen') {
			if ($this.data('spotlight-offset')) {
				var offsetHeight = $('body').find($this.data('spotlight-offset')).height();
				holderHeight = $(window).height() - offsetHeight;
			} else {
				holderHeight = $(window).height();
			}

			if ($(window).width() > 991) {
				$this.find('.spotlight-holder').css({
					'height': holderHeight + 'px'
				});
			} else {
				$this.find('.spotlight-holder').css({
					'height': 'auto'
				});
			}
		}

		$this.imagesLoaded().done(function(e) {
			$this.find(".animated").each(function() {
				var e = $(this);
				if (!e.hasClass("animation-ended")) {
					var t = e.data("animation-in"),
						a = (e.data("animation-out"), e.data("animation-delay"));
					setTimeout(function() {
						e.addClass("animation-ended " + t, 100).on(animEndEv, function() {
							e.removeClass(t)
						})
					}, a)
				}
			})
		})
	}

	function animate() {

	}

	// Events

	$(window).on({
		'load resize': function() {
			if ($spotlight.length) {
				$spotlight.each(function() {
					init($(this));
				});
			}
		}
	})

})();

//
// Google maps
//

var GoogleMapCustom = (function() {
    var $map = document.getElementById('map-custom'),
        lat,
        lng,
        color;

    function initMap(map) {

        lat = map.getAttribute('data-lat');
        lng = map.getAttribute('data-lng');
        color = map.getAttribute('data-color');

        var myLatlng = new google.maps.LatLng(lat, lng);
        var mapOptions = {
            zoom: 12,
            scrollwheel: false,
            center: myLatlng,
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            styles: [{"featureType":"administrative","elementType":"labels.text.fill","stylers":[{"color":"#444444"}]},{"featureType":"landscape","elementType":"all","stylers":[{"color":"#f2f2f2"}]},{"featureType":"poi","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"road","elementType":"all","stylers":[{"saturation":-100},{"lightness":45}]},{"featureType":"road.highway","elementType":"all","stylers":[{"visibility":"simplified"}]},{"featureType":"road.arterial","elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"featureType":"transit","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"water","elementType":"all","stylers":[{"color":color},{"visibility":"on"}]}]
        }

        map = new google.maps.Map(map, mapOptions);

        var marker = new google.maps.Marker({
            position: myLatlng,
            map: map,
            animation: google.maps.Animation.DROP,
            title: 'Hello World!'
        });

        var contentString = '<div class="info-window-content"><h2>{{ site.product.name }} {{ site.product.name_long }}</h2>' +
            '<p>{{ site.product.description }}</p></div>';

        var infowindow = new google.maps.InfoWindow({
            content: contentString
        });

        google.maps.event.addListener(marker, 'click', function() {
            infowindow.open(map, marker);
        });
    }

    if (typeof($map) != 'undefined' && $map != null) {
        google.maps.event.addDomListener(window, 'load', initMap($map));
    }
})();

//
// Google maps
//

var GoogleMap = (function() {
    var $map = document.getElementById('map-default'),
        lat,
        lng;

    function initMap(map) {

        lat = map.getAttribute('data-lat');
        lng = map.getAttribute('data-lng');

        var myLatlng = new google.maps.LatLng(lat, lng);
        var mapOptions = {
            zoom: 12,
            scrollwheel: false,
            center: myLatlng,
            mapTypeId: google.maps.MapTypeId.ROADMAP,
        }

        map = new google.maps.Map(map, mapOptions);

        var marker = new google.maps.Marker({
            position: myLatlng,
            map: map,
            animation: google.maps.Animation.DROP,
            title: 'Hello World!'
        });

        var contentString = '<div class="info-window-content"><h2>{{ site.product.name }} {{ site.product.name_long }}</h2>' +
            '<p>{{ site.product.description }}</p></div>';

        var infowindow = new google.maps.InfoWindow({
            content: contentString
        });

        google.maps.event.addListener(marker, 'click', function() {
            infowindow.open(map, marker);
        });
    }

    if (typeof($map) != 'undefined' && $map != null) {
        google.maps.event.addDomListener(window, 'load', initMap($map));
    }
})();

//
// Autosize textarea
//

'use strict';

var TextareaAutosize = (function() {

	// Variables

	var $textarea = $('[data-toggle="autosize"]');


	// Methods

	function init() {
		autosize($textarea);
	}


	// Events

	if ($textarea.length) {
		init();
	}

})();

//
// Widget Calendar
//

'use strict';

if($('[data-toggle="widget-calendar"]')[0]) {
    $('[data-toggle="widget-calendar"]').fullCalendar({
        contentHeight: 'auto',
        theme: false,
        buttonIcons: {
            prev: ' fas fa-angle-left',
            next: ' fas fa-angle-right'
        },
        header: {
            right: 'next',
            center: 'title, ',
            left: 'prev'
        },
        defaultDate: '2018-12-01',
        editable: true,
        events: [

            {
                title: 'Call with Dave',
                start: '2018-11-18',
                end: '2018-11-18',
                className: 'bg-danger'
            },

            {
                title: 'Lunch meeting',
                start: '2018-11-21',
                end: '2018-11-22',
                className: 'bg-warning'
            },

            {
                title: 'All day conference',
                start: '2018-11-29',
                end: '2018-11-29',
                className: 'bg-success'
            },

            {
                title: 'Meeting with Mary',
                start: '2018-12-01',
                end: '2018-12-01',
                className: 'bg-info'
            },

            {
                title: 'Winter Hackaton',
                start: '2018-12-03',
                end: '2018-12-03',
                className: 'bg-danger'
            },

            {
                title: 'Digital event',
                start: '2018-12-07',
                end: '2018-12-09',
                className: 'bg-warning'
            },

            {
                title: 'Marketing event',
                start: '2018-12-10',
                end: '2018-12-10',
                className: 'bg-primary'
            },

            {
                title: 'Dinner with Family',
                start: '2018-12-19',
                end: '2018-12-19',
                className: 'bg-danger'
            },

            {
                title: 'Black Friday',
                start: '2018-12-23',
                end: '2018-12-23',
                className: 'bg-info'
            },

            {
                title: 'Cyber Week',
                start: '2018-12-02',
                end: '2018-12-02',
                className: 'bg-warning'
            },

        ]
    });

    //Display Current Date as Calendar widget header
    var mYear = moment().format('YYYY');
    var mDay = moment().format('dddd, MMM D');
    $('.widget-calendar-year').html(mYear);
    $('.widget-calendar-day').html(mDay);
}

//
// Countdown
//

'use strict';

var Countdown = (function() {

	// Variables

	var $countdown = $('.countdown');


	// Methods

	function init($this) {
		var date = $this.data('countdown-date'),
			template = '<div class="countdown-item"><span class="countdown-digit">%-D</span><span class="countdown-label countdown-days">day%!D</span></div>' +
			'<div class="countdown-item"><span class="countdown-digit">%H</span><span class="countdown-separator">:</span><span class="countdown-label">hours</span></div>' +
			'<div class="countdown-item"><span class="countdown-digit">%M</span><span class="countdown-separator">:</span><span class="countdown-label">minutes</span></div>' +
			'<div class="countdown-item"><span class="countdown-digit">%S</span><span class="countdown-label">seconds</span></div>';

		$this.countdown(date).on('update.countdown', function(event) {
			var $this = $(this).html(event.strftime('' + template));
		});
	}


	// Events

	if ($countdown.length) {
		$countdown.each(function() {
			init($(this));
		})
	}

})();

//
// Counter
//

'use strict';

! function(t) {
	t.fn.countTo = function(e) {
		return e = e || {}, t(this).each(function() {
			var a = t.extend({}, t.fn.countTo.defaults, {
					from: t(this).data("from"),
					to: t(this).data("to"),
					speed: t(this).data("speed"),
					refreshInterval: t(this).data("refresh-interval"),
					decimals: t(this).data("decimals")
				}, e),
				n = Math.ceil(a.speed / a.refreshInterval),
				o = (a.to - a.from) / n,
				r = this,
				l = t(this),
				f = 0,
				i = a.from,
				c = l.data("countTo") || {};

			function s(t) {
				var e = a.formatter.call(r, t, a);
				l.text(e)
			}
			l.data("countTo", c), c.interval && clearInterval(c.interval), c.interval = setInterval(function() {
				f++, s(i += o), "function" == typeof a.onUpdate && a.onUpdate.call(r, i);
				f >= n && (l.removeData("countTo"), clearInterval(c.interval), i = a.to, "function" == typeof a.onComplete && a.onComplete.call(r, i))
			}, a.refreshInterval), s(i)
		})
	}, t.fn.countTo.defaults = {
		from: 0,
		to: 0,
		speed: 1e3,
		refreshInterval: 100,
		decimals: 0,
		formatter: function(t, e) {
			return t.toFixed(e.decimals)
		},
		onUpdate: null,
		onComplete: null
	}
}(jQuery);


var Counter = (function() {

	// Variables

	var counter = '.counter',
		$counter = $(counter);


	// Methods

	function init($this) {
		inView(counter)
		.on('enter', function() {
			if(! $this.hasClass('counting-finished')) {
				$this.countTo({
					formatter: function(value, options) {
						return value.toFixed(options.decimals);
					},
					onUpdate: function(value) {
						//console.debug(this);
					},
					onComplete: function(value) {
						$(this).addClass('counting-finished');
					}
				});
			}
		})
	}


	// // Events

	if ($counter.length) {
		init($counter);
	}

})();

//
// Datepicker
//

'use strict';

var Datepicker = (function() {

	//
	// Variables
	//

	var $date = $('[data-toggle="date"]'),
		$datetime = $('[data-toggle="datetime"]'),
		$time = $('[data-toggle="time"]');


	//
	// Methods
	//

	function initDate($this) {

		var options = {
			enableTime: false,
			allowInput: true
		};

		$this.flatpickr(options);
	}

	function initDatetime($this) {

		var options = {
			enableTime: true,
			allowInput: true
		};

		$this.flatpickr(options);
	}

	function initTime($this) {

		var options = {
			noCalendar: true,
            enableTime: true,
			allowInput: true
		};

		$this.flatpickr(options);
	}


	//
	// Events
	//

	if ($date.length) {

		// Init selects
		$date.each(function() {
			initDate($(this));
		});
	}

	if ($datetime.length) {

		// Init selects
		$datetime.each(function() {
			initDatetime($(this));
		});
	}

	if ($time.length) {

		// Init selects
		$time.each(function() {
			initTime($(this));
		});
	}

})();

! function(a) {
	"use strict";
	var t = function() {
		this.$body = a("body")
	};
	t.prototype.init = function() {
		a('[data-toggle="dragula"]').each(function() {
			var t = a(this).data("containers"),
				n = [];
			if (t)
				for (var i = 0; i < t.length; i++) n.push(a("#" + t[i])[0]);
			else n = [a(this)[0]];
			var r = a(this).data("handle-class");
			r ? dragula(n, {
				moves: function(a, t, n) {
					return n.classList.contains(r)
				}
			}) : dragula(n)
		})
	}, a.Dragula = new t, a.Dragula.Constructor = t
}(window.jQuery),
function(a) {
	"use strict";
	a.Dragula.init()
}(window.jQuery);

//
// Dropzone
//

'use strict';

var Dropzones = (function() {

	// Variables

	var $dropzone = $('[data-toggle="dropzone"]');
	var $dropzonePreview = $('.dz-preview');

	// Methods

	function init($this) {
		var multiple = ($this.data('dropzone-multiple') !== undefined) ? true : false;
		var preview = $this.find($dropzonePreview);
		var currentFile = undefined;

		// Init options
		var options = {
			url: $this.data('dropzone-url'),
			thumbnailWidth: null,
			thumbnailHeight: null,
			previewsContainer: preview.get(0),
			previewTemplate: preview.html(),
			maxFiles: (!multiple) ? 1 : null,
			acceptedFiles: (!multiple) ? 'image/*' : null,
			init: function() {
				this.on("addedfile", function(file) {
					if (!multiple && currentFile) {
						this.removeFile(currentFile);
					}
					currentFile = file;
				})
			}
		}

		// Clear preview html
		preview.html('');

		// Init dropzone
		$this.dropzone(options)
	}

	function globalOptions() {
		Dropzone.autoDiscover = false;
	}


	// Events

	if ($dropzone.length) {

		// Set global options
		globalOptions();

		// Init dropzones
		$dropzone.each(function() {
			init($(this));
		});
	}


})();

//
// Fullcalendar
//

'use strict';

var Fullcalendar = (function() {

	// Variables

	var $calendar = $('[data-toggle="calendar"]');

	//
	// Methods
	//

	// Init
	function init($this) {

		// Calendar events

		var events = [{
			id: 1,
			title: "Call with Dave",
			start: "2019-04-18",
			allDay: !0,
			className: "bg-danger",
			description: "Nullam id dolor id nibh ultricies vehicula ut id elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus."
		}, {
			id: 2,
			title: "Lunch meeting",
			start: "2019-04-21",
			allDay: !0,
			className: "bg-warning",
			description: "Nullam id dolor id nibh ultricies vehicula ut id elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus."
		}, {
			id: 3,
			title: "All day conference",
			start: "2019-04-29",
			allDay: !0,
			className: "bg-success",
			description: "Nullam id dolor id nibh ultricies vehicula ut id elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus."
		}, {
			id: 4,
			title: "Meeting with Mary",
			start: "2019-05-01",
			allDay: !0,
			className: "bg-info",
			description: "Nullam id dolor id nibh ultricies vehicula ut id elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus."
		}, {
			id: 5,
			title: "Winter Hackaton",
			start: "2019-05-03",
			allDay: !0,
			className: "bg-danger",
			description: "Nullam id dolor id nibh ultricies vehicula ut id elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus."
		}, {
			id: 6,
			title: "Digital event",
			start: "2019-05-07",
			allDay: !0,
			className: "bg-warning",
			description: "Nullam id dolor id nibh ultricies vehicula ut id elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus."
		}, {
			id: 7,
			title: "Marketing event",
			start: "2019-05-10",
			allDay: !0,
			className: "bg-primary",
			description: "Nullam id dolor id nibh ultricies vehicula ut id elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus."
		}, {
			id: 8,
			title: "Dinner with Family",
			start: "2019-05-19",
			allDay: !0,
			className: "bg-danger",
			description: "Nullam id dolor id nibh ultricies vehicula ut id elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus."
		}, {
			id: 9,
			title: "Black Friday",
			start: "2019-05-23",
			allDay: !0,
			className: "bg-info",
			description: "Nullam id dolor id nibh ultricies vehicula ut id elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus."
		}, {
			id: 10,
			title: "Cyber Week",
			start: "2019-05-02",
			allDay: !0,
			className: "bg-yellow",
			description: "Nullam id dolor id nibh ultricies vehicula ut id elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus."
		}],


		// Full calendar options
		// For more options read the official docs: https://fullcalendar.io/docs

		options = {
			header: {
				right: '',
				center: '',
				left: ''
			},
			buttonIcons: {
				prev: 'calendar--prev',
				next: 'calendar--next'
			},
			theme: false,
			selectable: true,
			selectHelper: true,
			editable: true,
			events: events,

			dayClick: function(date) {
				var isoDate = moment(date).toISOString();
				$('#new-event').modal('show');
				$('.new-event--title').val('');
				$('.new-event--start').val(isoDate);
				$('.new-event--end').val(isoDate);
			},

			viewRender: function(view) {
				var calendarDate = $this.fullCalendar('getDate');
				var calendarMonth = calendarDate.month();

				//Set data attribute for header. This is used to switch header images using css
				// $this.find('.fc-toolbar').attr('data-calendar-month', calendarMonth);

				//Set title in page header
				$('.fullcalendar-title').html(view.title);
			},

			// Edit calendar event action

			eventClick: function(event, element) {
				$('#edit-event input[value=' + event.className + ']').prop('checked', true);
				$('#edit-event').modal('show');
				$('.edit-event--id').val(event.id);
				$('.edit-event--title').val(event.title);
				$('.edit-event--description').val(event.description);
			}
		};

		// Initalize the calendar plugin
		$this.fullCalendar(options);


		//
		// Calendar actions
		//


		//Add new Event

		$('body').on('click', '.new-event--add', function() {
			var eventTitle = $('.new-event--title').val();

			// Generate ID
			var GenRandom = {
				Stored: [],
				Job: function() {
					var newId = Date.now().toString().substr(6); // or use any method that you want to achieve this string

					if (!this.Check(newId)) {
						this.Stored.push(newId);
						return newId;
					}
					return this.Job();
				},
				Check: function(id) {
					for (var i = 0; i < this.Stored.length; i++) {
						if (this.Stored[i] == id) return true;
					}
					return false;
				}
			};

			if (eventTitle != '') {
				$this.fullCalendar('renderEvent', {
					id: GenRandom.Job(),
					title: eventTitle,
					start: $('.new-event--start').val(),
					end: $('.new-event--end').val(),
					allDay: true,
					className: $('.event-tag input:checked').val()
				}, true);

				$('.new-event--form')[0].reset();
				$('.new-event--title').closest('.form-group').removeClass('has-danger');
				$('#new-event').modal('hide');
			} else {
				$('.new-event--title').closest('.form-group').addClass('has-danger');
				$('.new-event--title').focus();
			}
		});


		//Update/Delete an Event
		$('body').on('click', '[data-calendar]', function() {
			var calendarAction = $(this).data('calendar');
			var currentId = $('.edit-event--id').val();
			var currentTitle = $('.edit-event--title').val();
			var currentDesc = $('.edit-event--description').val();
			var currentClass = $('#edit-event .event-tag input:checked').val();
			var currentEvent = $this.fullCalendar('clientEvents', currentId);

			//Update
			if (calendarAction === 'update') {
				if (currentTitle != '') {
					currentEvent[0].title = currentTitle;
					currentEvent[0].description = currentDesc;
					currentEvent[0].className = [currentClass];

					console.log(currentClass);
					$this.fullCalendar('updateEvent', currentEvent[0]);
					$('#edit-event').modal('hide');
				} else {
					$('.edit-event--title').closest('.form-group').addClass('has-error');
					$('.edit-event--title').focus();
				}
			}

			//Delete
			if (calendarAction === 'delete') {
				$('#edit-event').modal('hide');

				// Show confirm dialog
				setTimeout(function() {
					swal({
						title: 'Are you sure?',
						text: "You won't be able to revert this!",
						type: 'warning',
						showCancelButton: true,
						buttonsStyling: false,
						confirmButtonClass: 'btn btn-danger',
						confirmButtonText: 'Yes, delete it!',
						cancelButtonClass: 'btn btn-secondary'
					}).then(function(result) {
						if (result.value) {
							// Delete event
							$this.fullCalendar('removeEvents', currentId);

							// Show confirmation
							swal({
								title: 'Deleted!',
								text: 'The event has been deleted.',
								type: 'success',
								buttonsStyling: false,
								confirmButtonClass: 'btn btn-primary'
							});
						}
					})
				}, 200);
			}
		});


		//Calendar views switch
		$('body').on('click', '[data-calendar-view]', function(e) {
			e.preventDefault();

			$('[data-calendar-view]').removeClass('active');
			$(this).addClass('active');

			var calendarView = $(this).attr('data-calendar-view');
			$this.fullCalendar('changeView', calendarView);
		});


		//Calendar Next
		$('body').on('click', '.fullcalendar-btn-next', function(e) {
			e.preventDefault();
			$this.fullCalendar('next');
		});


		//Calendar Prev
		$('body').on('click', '.fullcalendar-btn-prev', function(e) {
			e.preventDefault();
			$this.fullCalendar('prev');
		});
	}


	//
	// Events
	//

	// Init
	if ($calendar.length) {
		init($calendar);
	}

})();

//
// Highlight.js
//

'use strict';

var Highlight = (function() {

	//
	// Variables
	//

	var $highlight = $('.highlight');


	//
	// Methods
	//

	function init(i, block) {
		// Insert the copy button inside the highlight block
		var btnHtml = '<button class="action-item btn-clipboard" title="Copy to clipboard"><i class="far fa-copy mr-2"></i>Copy</button>'
		$(block).before(btnHtml)
		$('.btn-clipboard')
			.tooltip()
			.on('mouseleave', function() {
				// Explicitly hide tooltip, since after clicking it remains
				// focused (as it's a button), so tooltip would otherwise
				// remain visible until focus is moved away
				$(this).tooltip('hide');
			});

		// Component code copy/paste
		var clipboard = new ClipboardJS('.btn-clipboard', {
			target: function(trigger) {
				return trigger.nextElementSibling
			}
		})

		clipboard.on('success', function(e) {
			$(e.trigger)
				.attr('title', 'Copied!')
				.tooltip('_fixTitle')
				.tooltip('show')
				.attr('title', 'Copy to clipboard')
				.tooltip('_fixTitle')

			e.clearSelection()
		})

		clipboard.on('error', function(e) {
			var modifierKey = /Mac/i.test(navigator.userAgent) ? '\u2318' : 'Ctrl-'
			var fallbackMsg = 'Press ' + modifierKey + 'C to copy'

			$(e.trigger)
				.attr('title', fallbackMsg)
				.tooltip('_fixTitle')
				.tooltip('show')
				.attr('title', 'Copy to clipboard')
				.tooltip('_fixTitle')
		})

		// Initialize highlight.js plugin
		hljs.highlightBlock(block);
	}


	//
	// Events
	//

	$highlight.each(function(i, block) {
		init(i, block);
	});

})();

//
// List.js
//

'use strict';

var SortList = (function() {

	//  //
	// Variables
	//  //

	var $lists = $('[data-toggle="list"]');
	var $listsSort = $('[data-sort]');


	//
	// Methods
	//

	// Init
	function init($list) {
		new List($list.get(0), getOptions($list));
	}

	// Get options
	function getOptions($list) {
		var options = {
			valueNames: $list.data('list-values'),
			listClass: $list.data('list-class') ? $list.data('list-class') : 'list'
		}

		return options;
	}


	//
	// Events
	//

	// Init
	if ($lists.length) {
		$lists.each(function() {
			init($(this));
		});
	}

	// Sort
	$listsSort.on('click', function() {
		return false;
	});

})();

//
// Isotope - Masonry Layout
//

'use strict';

var Masonry = (function() {

	// Variables

	var $masonryContainer = $(".masonry-container");


	// Methods

	function init($this) {
		var $el = $this.find('.masonry'),
			$filters = $this.find('.masonry-filter-menu'),
			$defaultFilter = $filters.find('.active'),
			defaultFilterValue = $defaultFilter.data('filter');

		var $masonry = $el.imagesLoaded(function() {

			// Set default filter if exists

			if (defaultFilterValue != undefined && defaultFilterValue != '') {

				if (defaultFilterValue != '*') {
					defaultFilterValue = '.' + defaultFilterValue;
				}

				$defaultFilter.addClass('active');
			}


			// Plugin options
			var options = {
				itemSelector: '.masonry-item',
				filter: defaultFilterValue
			};

			// Init plugin
			$masonry.isotope(options);
		});


		// Sorting buttons (filters)

        $filters.on('click', 'a', function(e) {
			e.preventDefault();

			var $this = $(this),
             	val = $(this).attr('data-filter');

            if (val == '*') {
                val = '';
            } else {
                val = '.' + val;
            }

            $masonry.isotope({
                filter: val
            }).on( 'arrangeComplete', function() {
				$filters.find('[data-filter]').removeClass('active');
				$this.addClass('active');
			} );
        });

	}


	// Events

	if ($masonryContainer.length) {
		$masonryContainer.each(function() {
			init($(this));
		})
	}

})();

//
// Notify
// init of the bootstrap-notify plugin
//

'use strict';

var Notify = (function() {

	// Variables

	var $notifyBtn = $('[data-toggle="notify"]');


	// Methods

	function notify(placement, align, icon, type, animIn, animOut) {
		$.notify({
			icon: icon,
			title: ' Bootstrap Notify',
			message: 'Turning standard Bootstrap alerts into awesome notifications',
			url: ''
		}, {
			element: 'body',
			type: type,
			allow_dismiss: true,
			placement: {
				from: placement,
				align: align
			},
			offset: {
				x: 15, // Keep this as default
				y: 15 // Unless there'll be alignment issues as this value is targeted in CSS
			},
			spacing: 10,
			z_index: 1080,
			delay: 2500,
			timer: 25000,
			url_target: '_blank',
			mouse_over: false,
			animate: {
				// enter: animIn,
				// exit: animOut
                enter: animIn,
                exit: animOut
			},
			template:   '<div class="alert alert-{0} alert-icon alert-group alert-notify" data-notify="container" role="alert">' +
					  		'<div class="alert-group-prepend align-self-start">' +
					  			'<span class="alert-group-icon"><i data-notify="icon"></i></span>' +
					  		'</div>' +
					  		'<div class="alert-content">' +
								'<strong data-notify="title">{1}</strong>' +
								'<div data-notify="message">{2}</div>' +
							'</div>' +
					  		'<button type="button" class="close" data-notify="dismiss" aria-label="Close">' +
								'<span aria-hidden="true">&times;</span>' +
							'</button>' +
						'</div>'

		});
	}

	// Events

	if ($notifyBtn.length) {
		$notifyBtn.on('click', function(e) {
			e.preventDefault();

			var placement = $(this).attr('data-placement');
			var align = $(this).attr('data-align');
			var icon = $(this).attr('data-icon');
			var type = $(this).attr('data-type');
			var animIn = $(this).attr('data-animation-in');
			var animOut = $(this).attr('data-animation-out');

			notify(placement, align, icon, type, animIn, animOut);
		})
	}

})();

//
// No Ui Slider
//

'use strict';


//
// Single slider
//

var SingleSlider = (function() {

	// Variables

	var $sliderContainer = $(".input-slider-container");


	// Methods

	function init($this) {
		var $slider = $this.find('.input-slider');
		var sliderId = $slider.attr('id');
		var minValue = $slider.data('range-value-min');
		var maxValue = $slider.data('range-value-max');

		var sliderValue = $this.find('.range-slider-value');
		var sliderValueId = sliderValue.attr('id');
		var startValue = sliderValue.data('range-value-low');

		var c = document.getElementById(sliderId),
			d = document.getElementById(sliderValueId);

		var options = {
			start: [parseInt(startValue)],
			connect: [true, false],
			//step: 1000,
			range: {
				'min': [parseInt(minValue)],
				'max': [parseInt(maxValue)]
			}
		}

		noUiSlider.create(c, options);

		c.noUiSlider.on('update', function(a, b) {
			d.textContent = a[b];
		});
	}


	// Events

	if ($sliderContainer.length) {
		$sliderContainer.each(function() {
			init($(this));
		});
	}

})();


//
// Range slider
//

var RangeSlider = (function() {

	// Variables

	var $sliderContainer = $("#input-slider-range");


	// Methods

	function init($this) {
		var c = document.getElementById("input-slider-range"),
            d = document.getElementById("input-slider-range-value-low"),
            e = document.getElementById("input-slider-range-value-high"),
            f = [d, e];

        noUiSlider.create(c, {
            start: [parseInt(d.getAttribute('data-range-value-low')), parseInt(e.getAttribute('data-range-value-high'))],
            connect: !0,
            range: {
                min: parseInt(c.getAttribute('data-range-value-min')),
                max: parseInt(c.getAttribute('data-range-value-max'))
            }
        }), c.noUiSlider.on("update", function(a, b) {
            f[b].textContent = a[b]
        })
	}


	// Events

	if ($sliderContainer.length) {
		$sliderContainer.each(function() {
			init($(this));
		});
	}

})();

//
// Popover
//

'use strict';

var Popover = (function() {

	// Variables

	var $popover = $('[data-toggle="popover"]'),
		$popoverClass = '';


	// Methods

	function init($this) {
		if ($this.data('color')) {
			$popoverClass = 'popover-' + $this.data('color');
		}

		var options = {
			template: '<div class="popover ' + $popoverClass + '" role="tooltip"><div class="arrow"></div><h3 class="popover-header"></h3><div class="popover-body"></div></div>'
		};

		$this.popover(options);
	}


	// Events

	if ($popover.length) {
		$popover.each(function() {
			init($(this));
		});
	}

})();

//
// Popover
//

'use strict';

var ProgressCircle = (function() {

	// Variables

	var $progress = $('.progress-circle');

	// Methods

	function init($this) {

        var value = $this.data().progress,
			text = $this.data().text ? $this.data().text : '',
			textClass = $this.data().textclass ? $this.data().textclass : 'progressbar-text',
            color = $this.data().color ? $this.data().color : 'primary';

		var options = {
			color: PurposeStyle.colors.theme[color],
			strokeWidth: 7,
			trailWidth: 2,
			text: {
				value: text,
				className: textClass
			},
            svgStyle: {
                display: 'block',
            },
            duration: 1500,
            easing: 'easeInOut'
		};

		var progress = new ProgressBar.Circle($this[0], options);

        progress.animate(value / 100);
	}


	// Events

	if ($progress.length) {
		$progress.each(function() {
			init($(this));
		});
	}

})();

//
// Quill.js
//

'use strict';

var QuillEditor = (function() {

	// Variables

	var $quill = $('[data-toggle="quill"]');


	// Methods

	function init($this) {

		// Get placeholder
		var placeholder = $this.data('quill-placeholder');

		// Init editor
		var quill = new Quill($this.get(0), {
			modules: {
				toolbar: [
					['bold', 'italic'],
					['link', 'blockquote', 'code', 'image'],
					[{
						'list': 'ordered'
					}, {
						'list': 'bullet'
					}]
				]
			},
			placeholder: placeholder,
			theme: 'snow'
		});

	}

	// Events

	if ($quill.length) {
		$quill.each(function() {
			init($(this));
		});
	}

})();

//
// Scrollbar
//

'use strict';

var Scrollbar = (function() {

	// Variables

	var $scrollbar = $('.scrollbar-inner');


	// Methods

	function init() {
		$scrollbar.scrollbar().scrollLock()
	}


	// Events

	if ($scrollbar.length) {
		init();
	}

})();

//
// Select2
//

'use strict';

var Select = (function() {

	// Variables

	var $select = $('[data-toggle="select"]');

	// Methods

	function init($this) {
		var options = {};

		$this.select2(options);
	}

	function formatAvatar(avatar) {
		if (!avatar.id) {
			return avatar.text;
		}

		var $option = $(avatar.element);
		var optionAvatar = $option.data('avatar-src');
		var output;

		if (optionAvatar) {
			output = $('<span class="avatar avatar-xs mr-3"><img class="avatar-img rounded-circle" src="' + optionAvatar + '" alt="' + avatar.text + '"></span><span>' + avatar.text + '</span>');
		} else {
			output = avatar.text;
		}

		return output;
	}

	// Events

	if ($select.length) {

		// Init selects
		$select.each(function() {
			init($(this));
		});
	}

})();

//
// Sticky
//

'use strict';

var Sticky = (function() {

	//
	// Variables
	//

	var $sticky = $('[data-toggle="sticky"]');


	//
	// Methods
	//

	function init($this) {

		var offset = $this.data('sticky-offset') ? $this.data('sticky-offset') : 0;
		var options = {
			'offset_top': offset
		};

		if($(window).width() > 1000) {
			$this.stick_in_parent(options);
		} else {
			$this.trigger("sticky_kit:detach");
		}
	}


	//
	// Events
	//

	$(window).on('load resize', function() {
		if ($sticky.length) {

			// Init selects
			$sticky.each(function() {
				init($(this));
			});
		}
	})


})();

//
// Sticky
//

'use strict';

var SvgInjector = (function() {

	//
	// Variables
	//

	var $svg = document.querySelectorAll('img.svg-inject');


	//
	// Methods
	//

	function init($this) {

		var options = {

		};

		SVGInjector($this)
	}


	//
	// Events
	//

	if ($svg.length) {
		init($svg);
	}

})();

//
// Swiper
// init of plugin Swiper JS
//

'use strict';

var WpxSwiper = (function() {

	// Variables

	var $swiperContainer = $(".swiper-js-container"),
	 	animEndEv = 'webkitAnimationEnd animationend';


	// Methods

	function init($this) {

		// Swiper elements

        var $el = $this.find('.swiper-container'),
			pagination = $this.find('.swiper-pagination'),
			navNext = $this.find('.swiper-button-next'),
			navPrev = $this.find('.swiper-button-prev');


		// Swiper options

        var effect = $el.data('swiper-effect') ? $el.data('swiper-effect') : 'slide',
        	direction = $el.data('swiper-direction') ? $el.data('swiper-direction') :  'horizontal',
			initialSlide = $el.data('swiper-initial-slide') ? $el.data('swiper-initial-slide') : 0,
			autoHeight = $el.data('swiper-autoheight') ? $el.data('swiper-autoheight') : false,
			autoplay = $el.data('swiper-autoplay') ? $el.data('swiper-autoplay') : false,
			centeredSlides = $el.data('swiper-centered-slides') ? $el.data('swiper-centered-slides') : false,
			paginationType = $el.data('swiper-pagination-type') ? $el.data('swiper-pagination-type') : 'bullets';



		// Items per slide

        var items = $el.data('swiper-items');
        var itemsSm = $el.data('swiper-sm-items');
        var itemsMd = $el.data('swiper-md-items');
        var itemsLg = $el.data('swiper-lg-items');
		var itemsXl = $el.data('swiper-xl-items');


		// Space between items

        var spaceBetween = $el.data('swiper-space-between');
        var spaceBetweenSm = $el.data('swiper-sm-space-between');
        var spaceBetweenMd = $el.data('swiper-md-space-between');
        var spaceBetweenLg = $el.data('swiper-lg-space-between');
		var spaceBetweenXl = $el.data('swiper-xl-space-between');


		// Slides per view written in data attributes for adaptive resoutions

        items = items ? items : 1;
        itemsSm = itemsSm ? itemsSm : items;
		itemsMd = itemsMd ? itemsMd : itemsSm;
        itemsLg = itemsLg ? itemsLg : itemsMd;
        itemsXl = itemsXl ? itemsXl : itemsLg;


        // Space between slides written in data attributes for adaptive resoutions

        spaceBetween = !spaceBetween ? 0 : spaceBetween;
        spaceBetweenSm = !spaceBetweenSm ? spaceBetween : spaceBetweenSm;
        spaceBetweenMd = !spaceBetweenMd ? spaceBetweenSm : spaceBetweenMd;
        spaceBetweenLg = !spaceBetweenLg ? spaceBetweenMd : spaceBetweenLg;
		spaceBetweenXl = !spaceBetweenXl ? spaceBetweenLg : spaceBetweenXl;

		var $swiper = new Swiper($el, {
            pagination: {
                el: pagination,
                clickable: true,
				type: paginationType
            },
            navigation: {
                nextEl: navNext,
                prevEl: navPrev,
            },
            slidesPerView: items,
            spaceBetween: spaceBetween,
            initialSlide: initialSlide,
            autoHeight: autoHeight,
            centeredSlides: centeredSlides,
            mousewheel: false,
			keyboard: {
			    enabled: true,
			    onlyInViewport: false,
			},
            grabCursor: true,
			autoplay: autoplay,
            effect: effect,
            coverflowEffect: {
                rotate: 10,
                stretch: 0,
                depth: 50,
                modifier: 3,
                slideShadows: false
            },
            speed: 800,
            direction: direction,
            preventClicks: true,
            preventClicksPropagation: true,
            observer: true,
            observeParents: true,
			breakpointsInverse: true,
			breakpoints: {
                575: {
                    slidesPerView: itemsSm,
                    spaceBetweenSlides: spaceBetweenSm
                },
                767: {
                    slidesPerView: itemsMd,
                    spaceBetweenSlides: spaceBetweenMd
                },
                991: {
                    slidesPerView: itemsLg,
                    spaceBetweenSlides: spaceBetweenLg
                },
                1199: {
                    slidesPerView: itemsXl,
                    spaceBetweenSlides: spaceBetweenXl
                }
            }
        });
	}


	// Events
	$(document).ready(function() {
		if ($swiperContainer.length) {
			$swiperContainer.each(function(i, swiperContainer) {
				init($(swiperContainer));
			})
		}
	})

})();

//
// Tags input
//

'use strict';

var Tags = (function() {

	//
	// Variables
	//

	var $tags = $('[data-toggle="tags"]');


	//
	// Methods
	//

	function init($this) {

		var options = {
			tagClass: 'badge badge-primary'
		};

		$this.tagsinput(options);
	}


	//
	// Events
	//

	if ($tags.length) {

		// Init selects
		$tags.each(function() {
			init($(this));
		});
	}

})();

//
// Typed
// text typing animation
//

'use strict';

var Typed = (function() {

	// Variables

	var typed = '.typed',
		$typed = $(typed);


	// Methods

	function init($this) {
		var el = '#' + $this.attr('id'),
        	strings = $this.data('type-this'),
			strings = strings.split(',');

		var options = {
			strings: strings,
            typeSpeed: 100,
            backSpeed: 70,
            loop: true
		};

        var animation = new Typed(el, options);

		inView(el).on('enter', function() {
			animation.start();
		}).on('exit', function() {
			animation.stop();
		});
	}


	// Events

	if ($typed.length) {
		$typed.each(function() {
			init($(this));
		});
	}

})();

//
// Wavify
//

'use strict';

var Wavify = (function() {

	//
	// Variables
	//

	var $wavify = $('[data-toggle="wavify"]');


	//
	// Methods
	//

	function init($this) {
		var $path = $this.find('path');

		var options = {
			height: 50,
            bones: 5,
            amplitude: 40,
            speed: .15
		};

		$path.wavify(options);
	}


	//
	// Events
	//

	if ($wavify.length) {

		// Init selects
		$wavify.each(function() {
			init($(this));
		});
	}

})();

//
// Engagement chart
//

'use strict';

var EngagementChart = (function() {

	// Variables

	var $chart = $('#apex-engagement');

	// Methods
	function init($this) {

		// Options
		var options = {
			chart: {
				width: '100%',
				zoom: {
					enabled: false
				},
				toolbar: {
					show: false
				},
				shadow: {
					enabled: false,
				},
			},
			stroke: {
				width: 7,
				curve: 'smooth'
			},
			series: [{
				name: 'Likes',
				data: [4, 3, 10, 9, 29, 19, 22, 9]
			}],
			xaxis: {
				labels: {
                    format: 'MMM',
					style: {
						colors: PurposeStyle.colors.gray[600],
						fontSize: '14px',
						fontFamily: PurposeStyle.fonts.base,
						cssClass: 'apexcharts-xaxis-label',
					},
				},
                axisBorder: {
                    show: false
                },
                axisTicks: {
                    show: true,
                    borderType: 'solid',
                    color: PurposeStyle.colors.gray[300],
                    height: 6,
                    offsetX: 0,
                    offsetY: 0
                },
				type: 'datetime',
				categories: ['1/11/2000', '2/11/2000', '3/11/2000', '4/11/2000', '5/11/2000', '6/11/2000', '7/11/2000', '8/11/2000'],
			},
            yaxis: {
				labels: {
					style: {
						color: PurposeStyle.colors.gray[600],
						fontSize: '12px',
						fontFamily: PurposeStyle.fonts.base,
					},
				},
                axisBorder: {
                    show: false
                },
                axisTicks: {
                    show: true,
                    borderType: 'solid',
                    color: PurposeStyle.colors.gray[300],
                    height: 6,
                    offsetX: 0,
                    offsetY: 0
                }
			},
			fill: {
				type: 'solid'
			},
			markers: {
				size: 4,
				opacity: 0.7,
				strokeColor: "#fff",
				strokeWidth: 3,
				hover: {
					size: 7,
				}
			},
			grid: {
				borderColor: PurposeStyle.colors.gray[300],
				strokeDashArray: 5,
			},
			dataLabels: {
				enabled: false
			}
		}

		// Get data from data attributes
		var dataset = $this.data().dataset,
			labels = $this.data().labels,
			color = $this.data().color,
			height = $this.data().height,
			type = $this.data().type;

		// Inject synamic properties
        options.colors = [
            PurposeStyle.colors.theme[color]
        ];

        options.markers.colors = [
            PurposeStyle.colors.theme[color]
        ];

		options.chart.height = height ? height : 350;

		options.chart.type = type ? type : 'line';

		// Init chart
		var chart = new ApexCharts($this[0], options);

		// Draw chart
		setTimeout(function() {
			chart.render();
		}, 300);

	}

	// Events

	if ($chart.length) {
		$chart.each(function() {
			init($(this));
		});
	}

})();

//
// Line chart
//

'use strict';

var LineChart = (function() {

	// Variables

	var $chart = $('#apex-line');

	// Methods
	function init($this) {

		// Options
		var options = {
			chart: {
				zoom: {
					enabled: false
				},
				toolbar: {
					show: false
				},
				shadow: {
					enabled: false,
				},
			},
			stroke: {
				width: 7,
				curve: 'smooth'
			},
			series: [{
				name: 'Likes',
				data: [4, 3, 10, 9, 29, 19, 22, 9, 12, 7, 19, 5, 13, 9]
			}],
			xaxis: {
				labels: {
                    format: 'MMM',
					style: {
						colors: PurposeStyle.colors.gray[600],
						fontSize: '14px',
						fontFamily: PurposeStyle.fonts.base,
						cssClass: 'apexcharts-xaxis-label',
					},
				},
                axisBorder: {
                    show: false
                },
                axisTicks: {
                    show: true,
                    borderType: 'solid',
                    color: PurposeStyle.colors.gray[300],
                    height: 6,
                    offsetX: 0,
                    offsetY: 0
                },
				type: 'datetime',
				categories: ['1/11/2000', '2/11/2000', '3/11/2000', '4/11/2000', '5/11/2000', '6/11/2000', '7/11/2000', '8/11/2000', '9/11/2000', '10/11/2000', '11/11/2000', '12/11/2000', '1/11/2001', '2/11/2001'],
			},
            yaxis: {
				labels: {
					style: {
						color: PurposeStyle.colors.gray[600],
						fontSize: '12px',
						fontFamily: PurposeStyle.fonts.base,
					},
				},
                axisBorder: {
                    show: false
                },
                axisTicks: {
                    show: true,
                    borderType: 'solid',
                    color: PurposeStyle.colors.gray[300],
                    height: 6,
                    offsetX: 0,
                    offsetY: 0
                }
			},
			fill: {
				type: 'solid'
			},
			markers: {
				size: 4,
				opacity: 0.7,
				strokeColor: "#fff",
				strokeWidth: 3,
				hover: {
					size: 7,
				}
			},
			grid: {
				borderColor: PurposeStyle.colors.gray[300],
				strokeDashArray: 5,
			},
			dataLabels: {
				enabled: false
			}
		}

		// Get data from data attributes
		var dataset = $this.data().dataset,
			labels = $this.data().labels,
			color = $this.data().color,
			height = $this.data().height,
			type = $this.data().type;

		// Inject synamic properties
        options.colors = [
            PurposeStyle.colors.theme[color]
        ];

        options.markers.colors = [
            PurposeStyle.colors.theme[color]
        ];

		options.chart.height = height ? height : 350;

		options.chart.type = type ? type : 'line';

		// Init chart
		var chart = new ApexCharts($this[0], options);

		// Draw chart
		setTimeout(function() {
			chart.render();
		}, 300);

	}

	// Events

	if ($chart.length) {
		$chart.each(function() {
			init($(this));
		});
	}

})();

//
// Spark chart
//

'use strict';

var SparkChart = (function() {

	// Variables

	var $chart = $('[data-toggle="spark-chart"]');

	// Methods
	function init($this) {

        // Options
		var options = {
			chart: {
                width: '100%',
				sparkline: {
					enabled: true
				}
			},
			series: [],
			labels: [],
			stroke: {
				width: 2,
				curve: "smooth"
			},
			markers: {
				size: 0
			},
            colors: [],
			tooltip: {
				fixed: {
					enabled: false
				},
				x: {
					show: false
				},
				y: {
					title: {
						formatter: function(e) {
							return ""
						}
					}
				},
				marker: {
					show: !1
				}
			}
		}

        // Get data from data attributes
        var dataset = $this.data().dataset,
			labels = $this.data().labels,
            color = $this.data().color,
            height = $this.data().height,
            type = $this.data().type;

        // Inject synamic properties
        options.series = [{
            data: dataset
        }];

		if(labels) {
			options.labels = [labels];	
		}

        options.colors = [
            PurposeStyle.colors.theme[color]
        ];

        options.chart.height = height ? height : 35;

        options.chart.type = type ? type : 'line';

        // Init chart
        var chart = new ApexCharts($this[0], options);

        // Draw chart
		setTimeout(function(){
			chart.render();
		}, 300);

	}

	// Events

	if ($chart.length) {
		$chart.each(function() {
            init($(this));
        });
	}

})();

//
// Worked hours chart
//

'use strict';

var WorkedHoursChart = (function() {

	// Variables

	var $chart = $('#apex-worked-hours');

	// Methods
	function init($this) {

		// Options
		var options = {
			chart: {
				width: '100%',
				type: 'bar',
				zoom: {
					enabled: false
				},
				toolbar: {
					show: false
				},
				shadow: {
					enabled: false,
				},
			},
			plotOptions: {
                bar: {
                    horizontal: false,
                    columnWidth: '30%',
                    endingShape: 'rounded'
                },
            },
			stroke: {
                show: true,
                width: 2,
                colors: ['transparent']
            },
			series: [{
				name: 'Worked hours',
				data: [40, 30, 100, 90, 20]
			}],
			xaxis: {
				labels: {
                    format: 'MMM',
					style: {
						colors: PurposeStyle.colors.gray[600],
						fontSize: '14px',
						fontFamily: PurposeStyle.fonts.base,
						cssClass: 'apexcharts-xaxis-label',
					},
				},
                axisBorder: {
                    show: false
                },
                axisTicks: {
                    show: true,
                    borderType: 'solid',
                    color: PurposeStyle.colors.gray[300],
                    height: 6,
                    offsetX: 0,
                    offsetY: 0
                },
				type: 'datetime',
				categories: ['1/11/2000', '2/11/2000', '3/11/2000', '4/11/2000', '5/11/2000'],
			},
            yaxis: {
				labels: {
					style: {
						color: PurposeStyle.colors.gray[600],
						fontSize: '12px',
						fontFamily: PurposeStyle.fonts.base,
					},
				},
                axisBorder: {
                    show: false
                },
                axisTicks: {
                    show: true,
                    borderType: 'solid',
                    color: PurposeStyle.colors.gray[300],
                    height: 6,
                    offsetX: 0,
                    offsetY: 0
                }
			},
			fill: {
				type: 'solid'
			},
			markers: {
				size: 4,
				opacity: 0.7,
				strokeColor: "#fff",
				strokeWidth: 3,
				hover: {
					size: 7,
				}
			},
			grid: {
				borderColor: PurposeStyle.colors.gray[300],
				strokeDashArray: 5,
			},
			dataLabels: {
				enabled: false
			}
		}

		// Get data from data attributes
		var dataset = $this.data().dataset,
			labels = $this.data().labels,
			color = $this.data().color,
			height = $this.data().height,
			type = $this.data().type;

		// Inject synamic properties
        options.colors = [
            PurposeStyle.colors.theme[color]
        ];

        options.markers.colors = [
            PurposeStyle.colors.theme[color]
        ];

		options.chart.height = height ? height : 350;

		// Init chart
		var chart = new ApexCharts($this[0], options);

		// Draw chart
		setTimeout(function() {
			chart.render();
		}, 300);

	}

	// Events

	if ($chart.length) {
		$chart.each(function() {
			init($(this));
		});
	}

})();
