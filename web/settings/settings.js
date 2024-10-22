const titleContent = 'Telkomsel IoT';
const descriptionContent = 'Telkomsel IoT, powered by Flutter.';
const primaryColor = '#FF0036';

const title = document.createElement('title');
title.textContent = titleContent;
document.head.appendChild(title);

const appleMobileWebAppTitle = document.createElement('meta');
appleMobileWebAppTitle.setAttribute('name', 'apple-mobile-web-app-title');
appleMobileWebAppTitle.setAttribute('content', titleContent);
document.head.appendChild(appleMobileWebAppTitle);

const description = document.createElement('meta');
description.setAttribute('name', 'description');
description.setAttribute('content', descriptionContent);
document.head.appendChild(description);

const appleTouchIcon = document.createElement('link');
appleTouchIcon.setAttribute('rel', 'apple-touch-icon');
appleTouchIcon.setAttribute('href', 'settings/icons/Icon-192.png');
document.head.appendChild(appleTouchIcon);

const favicon = document.createElement('link');
favicon.setAttribute('rel', 'icon');
favicon.setAttribute('type', 'image/x-icon');
favicon.setAttribute('href', 'settings/favicon.ico');
document.head.appendChild(favicon);

const manifest = document.createElement('link');
manifest.setAttribute('rel', 'manifest');
manifest.setAttribute('href', 'settings/manifest.json');
document.head.appendChild(manifest);

document.documentElement.style.setProperty('--theme-color', primaryColor);
