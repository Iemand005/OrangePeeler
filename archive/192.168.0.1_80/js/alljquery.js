$('#closeWindow').live('click', function() {// close window
   $('body, html').animate({scrollTop : '0px'});
   $('.windowStyle').fadeOut();
   $('.blackBackground').hide();
});

$('#closeWindow01').live('click', function() {// close window
   $('body, html').animate({scrollTop : '0px'});
   $('.windowStyle01').fadeOut();
   $('.blackBackground').hide();
});

$('.button-on:not(.disabled)').live('click', function () {
	var e = $(this);
	if (!$(this).hasClass('no-action')) {
		var id = e.attr('id');
		var dir = 'hide';
		if (e.hasClass('reverse'))
			dir = 'show';

		if (e.hasClass('noAni')) {
			$('.' + id).animate({ height: dir }, 10);
		} else {
			$('.' + id).animate({ height: dir });
		}
	}
	e.toggleClass('button-on button-off');
});

$('.button-off:not(.disabled)').live('click', function () {
	var e = $(this);
	if (!$(this).hasClass('no-action')) {
		var id = e.attr('id');
		var dir = 'show';
		if (e.hasClass('reverse'))
			dir = 'hide';

		if (e.hasClass('noAni')) {
			$('.' + id).animate({ height: dir }, 10);
		} else {
			$('.' + id).animate({ height: dir });
		}
	}
	e.toggleClass('button-on button-off');
});

$('.checkbox-checked:not(.select-all, .not), .checkbox-unchecked:not(.select-all, .not)').live('click', function () {
	$(this).toggleClass('checkbox-checked checkbox-unchecked');
});

var timeout_val = 500;

$('.jq_apply').live('click', function() {
   $('body, html').animate({ scrollTop: '0px' });
   $('.loadingimg').fadeIn();
   $('.blackBackground').show();
	setTimeout(function(){
	   $('.loadingimg').fadeOut();
	   $('.blackBackground').hide();
	},timeout_val);
});

var sb_timeout_val = 30000;
$('.jq_sidebar').live('click', function() {
  $('body, html').animate({ scrollTop: '0px' });
  $('.loadingimg').fadeIn();
  $('.blackBackground').show();
  setTimeout(function(){
	   $('.loadingimg').fadeOut();
	   $('.blackBackground').hide();
  },sb_timeout_val);
});

$(function(){
	var href = $(".nav>div>ul>li:has(ul)>a").attr('href');
	$(".nav>ul>li:has(ul)>a").after('<a href="'+href+'"" class="menu-plus">▼</a>');//第二層
	$(".nav>ul>li>ul>li:has(ul)>a").after('<a href="'+href+'"" class="menu-plus">▼</a>');//第三層

	$("#m_top .nav>#nav-btn").click(function() {
		$("#m_top .nav>ul").slideToggle();
		return false;
	});

	$('.menu>li>.menu-plus').on('click', function(){
		 $(this).text(function(i, v) {
			return v === '▲' ? '▼' : '▲';
		})
		$(this).next('.sub-menu').slideToggle();
		return false;
	 });

	$('.sub-menu>li>.menu-plus').on('click', function(){
		 $(this).text(function(i, v) {
			return v === '▲' ? '▼' : '▲';
		})
		$(this).next('.sub-menu').slideToggle();
		return false;
	 });
});