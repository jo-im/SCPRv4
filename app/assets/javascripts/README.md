# JavaScript Assets

The JavaScript files in this directory serve as a way to enable dynamic interaction across the site. `aplicayshun.js` currently holds all the scripts required globally. You can find usage details for some major scripts below.

---

## `audio.js.coffee`

Our audio widgets are powered by a class called, `scpr.Audio`. Creating a new instance of `scpr.Audio` on a page with a few options indicating interactive elements (play button, audio bar element, etc.), will enable playback functionality for that page.

### Analytics

Events are sent to analytics in multiple ways.
- Google Analytics:
    - We use the `sendEvent` method to send AudioPlayer events to our GA. This includes events such as 'start', 'Quartile1', 'Quartile2, 'Quartile3', and 'complete'.
- Google Tag Manager:
    - We use the `addToDataLayer` method to push general purpose data to our GTM. This includes primitive events such as 'play', 'pause', and 'change'

#### How to verify events are sending

For Google Analytics:
- Open a page with an inline audio element
- Open the network tab in dev tools and filter by our GA id
- Click the 'play' button, and let it play to completion.
- Five events should have sent: 'start', 'Quartile1', 'Quartile2', 'Quartile3', 'complete'

For Google Tag Manager
- Go to GTM and turn on "Preview" mode
- Visit a page with multiple audio files, like this: https://scprv4-staging.scprdev.org/programs/take-two/2017/12/01/60481/cruising-through-the-2017-la-auto-show/
- Choose the dataLayer tab
- Click the play button
- A dataLayer object with `eventAction: play` should show up
- Minimize the GTM dev tool (because it's blocking the audio bar)
- Press pause, and then click the second audio element (or click the second audio element and then click pause)
- Maximize the GTM dev tool
- Two more dataLayer objects with `eventAction: pause` and `eventAction: change` should show up

---

## `listen_live.js.coffee`
The live stream is powered by a class called, `scpr.ListenLive`. Creating a new instance of `scpr.ListenLive` should enable live stream functionality for that page.

### Analytics

- Google Tag Manager:
    - We use the `_addToDataLayer` method to push general purpose data to our GTM. This includes primitive events such as 'play' and 'pause'

#### How to verify events are sending

- Go to GTM and turn on "Preview" mode
- Visit the live stream page
- Choose the dataLayer tab
- Click the play button
- A dataLayer object with `eventAction: play` should show up
- Minimize the GTM dev tool (because it's blocking the audio bar)
- Press pause
- Maximize the GTM dev tool
- One more dataLayer object with `eventAction: pause` should show up
