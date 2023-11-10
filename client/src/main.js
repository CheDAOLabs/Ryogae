import { createApp } from 'vue'
import ElementPlus from 'element-plus'
import 'element-plus/theme-chalk/dark/css-vars.css'
import 'element-plus/dist/index.css'
import App from './App.vue'
import {createRouter,createWebHashHistory} from 'vue-router'

const Home = { template: '<div>Home</div>' }
const About = { template: '<div>About</div>' }


const routes = [
    { path: '/', component: Home },
    { path: '/about', component: About },
]

const router = createRouter({
    history: createWebHashHistory(),
    routes
})


const app = createApp(App)

app.use(router);
app.use(ElementPlus)
app.mount('#app')