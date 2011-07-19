<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="misc" tagdir="/WEB-INF/tags" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>

<head>
    <misc:contenttype />
    <misc:title value="Home" />
    <link rel="stylesheet" type="text/css" href="css/reset.css" />
    <link rel="stylesheet" type="text/css" href="css/lib.css" />
    <link rel="stylesheet" type="text/css" href="css/main.css" />
    <link rel="stylesheet" type="text/css" href="css/showcase.css" />
</head>

<body>
	<div class="wrapper">
	    <misc:header />
	    
	    <div class="main group">
            <misc:showcase />
        
            <misc:launchers cssClass="box" />
                
            <div class="group">
                <misc:quote />
                <misc:popularwidgets />
                <div class="box span-2 last">
                    <ul id="twittercontent" class="avatar-list group"></ul>
                </div>
            </div>
		</div>
	</div>
    
	<misc:footer />
    
    <misc:jquery />
    <script src="js/menutab.js"></script>
    <script src="js/twitter.js"></script>
	<script>
		$(document).ready(function() {
			$("#twittercontent").performTwitterSearch(1, function(image, user, text, time){
				return '<li class="group"><img class="avatar" src="' + 
				image + '"/><div class="avatar-list-text"><div class="question-title">' +
				user + '</div><div class="question-text"><pre>' + 
				text + '</pre></div>' + '<div class="datetime">' + 
				time + '</div></div></li>';
			});
		});
	</script>
</body>

</html>