AdInject
========

The project includes the AdInjectLibrary and a sample example to show 
how to use the library to inject ads into your existing table views.

You just need to download the whole package and run the project within the package.
"AdInjector.h" and "AdInjector.m" are essentially the library files. The rest belongs
to the sample project.

The library (especially ad tracking) is not fully implemented due to limited time.
And also showing the ad in a UIWebView cause the app to exceed given CPU limitations
so the image and the url within the rich media is tried to be taken by using async 
NSURLConnections but again not enough time to complete it.

At first, it is a bit hard to understand what is expected from the library
and how to construct the library and the client architecture. To finish on time
I believe one needs to be familiar with the domain and existing sdks. That was the
main reason why I was not able to finish the assignment on time.
