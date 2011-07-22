<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="misc" tagdir="/WEB-INF/tags"%>
<%@ taglib prefix="menutabs" tagdir="/WEB-INF/tags/menutabs"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>

<head>
    <misc:contenttype />
    <misc:title value="Tracking" />
    <link rel="stylesheet" type="text/css" href="/css/reset.css" />
    <link rel="stylesheet" type="text/css" href="/css/lib.css" />
    <link rel="stylesheet" type="text/css" href="/css/main.css" />
    <link rel="stylesheet" type="text/css" href="/css/downloadmenu.css" />
    <link rel="stylesheet" type="text/css" href="/css/widget.css" />
    <link rel="stylesheet" type="text/css" href="/css/jquery.snippet.css" />


</head>

<body>
    <div class="wrapper">
        <misc:header />
        <div class="main">
			<div id="navigation">
			    <misc:launchers cssClass="menutab" />
			    <div class="navigation-tabs">
			        <div id="breadcrumbs" class="menubox"></div>
			        <menutabs:learn />
			        <menutabs:download />
			        <menutabs:talk />
			    </div>
			</div>
			<div class="content group">
				<div class="widget-content">
					<div class="widgetpreview">
							<div data-tab="code" class="tab codetab">
								<pre class="html">
&lt;script src=&quot;http://code.jquery.com/jquery-latest.js&quot;&gt;&lt;/script&gt;
&lt;script src=&quot;http://fraktguide.bring.no/fraktguide/js/utleveringsenhet-1.0.0.js&quot;&gt;&lt;/script&gt;

&lt;script type=&quot;text/javascript&quot;&gt;
   $(document).ready(function() {
      $(&#39;#divid&#39;).utleveringsenhet();
   });
&lt;/script&gt;

&lt;form&gt;
   &lt;div id=&quot;divid&quot;&gt;&lt;/div&gt;
&lt;/form&gt;
&lt;/form&gt;
&lt;/form&gt;
&lt;/form&gt;
						</pre>
							</div>
							<div data-tab="preview" class="tab previewtab">
								<form>
								   <div id="divid"></div>
								</form>
							</div>
							<div class="widget-tabs">
								<a href="#code" class="widget-tab">Code</a>
								<a href="#preview" class="widget-tab active">Widget Preview</a>
							</div>
					</div>
					<div class="widgetinfo">
						<div class="widgetarticle">
							<h1>Optional Post office</h1>
							<p>Optional post office is a service that allows an end user can choose to pick up their package at another post office / post office than the local. This can be done directly from the online store's image for the choice of shipping.</p>
							<h2>How to install</h2>
							<p>...</p>
							<h2>More information</h2>
							<p>...</p>
						</div>
						<div class="widget-tools">
							<h2>Tools</h2>
							<a href="#" class="download-button">Download</a> 
						</div>
					</div>
				</div>
				<misc:socialfeed />
            </div>
        </div>
    </div>
    
    <misc:footer />
    
    <misc:jqueryblob />
	<script src="http://fraktguide.bring.no/fraktguide/js/utleveringsenhet-1.0.0.js"></script>
    <script type="text/javascript" src="/js/jquery.snippet.min.js"></script>
    <script type="text/javascript" src="/js/syntaxhighligther.js"></script>
    <script>
        $(document).ready(function() {
            var sectionId = "#download";
            $("#navigation").menutab("init", {
                section: sectionId,
                tabs: [ "#learn", "#download", "#talk" ],
            });
            
			            // Tabs
			            var codetabs = $(".widgetpreview");

			            codetabs.each(function(i, tabscontanier) {

			                $(".tab", tabscontanier).each(function(i, tab) {
			                    $(tabscontanier).append($(tab));

			                    var tabName = $(tab).attr("data-tab");
			                    $(tab).data("tab-name", tabName);

			                    var triggers = $("a[href$=#" + tabName + "]", tabscontanier) ;
			                    $(triggers).each(function(i, trigger) {
			                        $(trigger).click(function(e) {
			                            e.preventDefault();
			                            var openTabName = $(trigger).attr("href").substring(1);
			//                             tabscontanier.showTab(openTabName);
			                            codetabs.showTab(openTabName);
			                        });
			                    });

			                    $(tab).data("tab-triggers", triggers);
			                });
			            });

			            codetabs.showTab = function(tabName) {
			                $(codetabs).each(function(i, tabscontainer) {
			                    tabscontainer.showTab(tabName);
			                });
			            };


			            // Add tab functinoality to tabscontainer
			            codetabs.each(function(i, tabscontainer) {
			                tabscontainer.showTab = function(tabName) {
			                    if(!tabName) return;
			                    //var tab = $("*[data-tab="+tabName+"]", tabscontainer);
			                    var tabs = $(".tab", tabscontainer);
			                    $(tabs).each(function(i, tab) {
			                        var curTabName = $(tab).data("tab-name");
			                        if(tabName === curTabName) {
			                            $(tab).show();
			                            $(tab).data("tab-triggers").addClass("active");
			                        }
			                        else {
			                            $(tab).hide();
			                            $(tab).data("tab-triggers").removeClass("active");
			                        }

			                        // TODO: triggers
			                    });
			                };
			            });
					
					
			codetabs.showTab("preview");
						
            $("#twittercontent").performTwitterSearch(3, function(image, user, text, time){
                return '<li class="group"><img class="avatar" src="' + 
                image + '"/><div class="avatar-list-text"><div class="question-title">' +
                user + '</div><div class="question-text"><blockquote>' + 
                text + '</blockquote></div>' + '<div class="datetime">' + 
                time + '</div></div></li>';
            });

			//widget preview
			  $('#divid').utleveringsenhet();
		    
        });
    </script>
</body>

</html>