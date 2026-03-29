// src/index.ts
// @ts-ignore
import { Elm } from './Framework.elm';

console.log("Vite is running index.ts"); 

const node = document.getElementById('elm-app');

if (node) {
    try {
        const app = Elm.Framework.init({
            node: node,
            flags: {
                width: window.innerWidth,
                height: window.innerHeight,
                locationHref: window.location.href
            }
        });
        console.log("Elm initialized successfully");
    } catch (e) {
        console.error("Elm failed to start:", e);
    }
} else {
    console.error("Could not find #elm-app div");
}