#     如何减下vue打包时的体积以加快页面加载速度



#### 	1 生产环境中设置config文件夹index.js,但是这样上线后不利于定位错误

​       生产环境中设置config文件夹index.js中productionSourceMap的值为false，也就是设置webpack配置中devtool为false，我本地devtool用#eval-source-map属性时打包体积为4.49M，改为false时打包体积为1.62M

#### 2 引用组件时直接引用组件

​       例如我们需要用vue-weui中的button.vue，如果这么引用会使打包文件变大

```js
import Button from 'vue-weui' 
```

这样的话想对来说会小点，对于较大的库，采取两种方式的差别是很大的

```js
import Button from 'vue-weui/components/button/button.vue'
```

#### 		 3 CDN引入第三方的不变的库

​	对于jquery,vue,vue-router第三方的不变的库可以在首页面以标签cdn的方式引入，然后配置webpack的配置 

我这次直接用标签引的vue,打包后体积还是减小了很多

```js
externals:{'jquery':'jQuery'}
```

#### 		 4 按需加载组件（可能涉及到es6语法写法略有不同）

​	假如一个页面由100个组件构成，用户访问这个页面时，显然不需要将所有组件都下载到本地，如他刚进入这个页面时，只需要访问header、login、footer这3个组件。我们可以将其他组件设置为异步组件，即需要的时候才加载配合webpack的require.ensure来实现将以前构建的那个大js切割为模块化

不进行页面按需加载引入方式 :

```js
import home from '../../common/home.vue'
```

进行页面按需加载的引入方式：

```js
const home = r => require.ensure([],() => r(require('../../common/home.vue')))
```

为了实现代码切割我们这么引入 , 相同 chunk名字的模块将会打包到一起

```js
const banana = r => require.ensure([],() => r(require('@/components/banana.vue')), 'chunkname3')
```

```js
const apple = r => require.ensure([],() => r(require('@/components/apple.vue')), 'chunkname2')
```

重新构建后发现原来的那个单个的js被切割为多个小组件的js 并且点击 不同的路由会按需加载对应js

#### 5 抽离vue内部的css

​	如果不提取css样式，vue内的style都会以style标签的形式被添加到页面的head里面，不利于资源的缓存而且降低了页面的加载速度，这里我简单介绍下抽离vue组件中的css，用到webpack的extract-text-webpack-plugin插件，先安装一下

```js
npm install extract-text-webpack-plugin --save-dev
```

在使用css相关loader之前先用本插件过滤一遍

```js
var ExtractTextPlugin = require("extract-text-webpack-plugin")
module.exports = {
    module: {
        rules: [
            {
                test: /\.vue$/,
                loader: 'vue-loader',
                options: {
                    loaders: {
                        css: ExtractTextPlugin.extract({
                            use: 'css-loader',
                            fallback: 'vue-style-loader' //这是vue-loader的依赖
                        }),
                        //用了less或者sass的地方都要用上
                        'less': ExtractTextPlugin.extract({
                            use: [
                                'css-loader',
                                'less-loader'
                            ],
                            fallback: 'vue-style-loader'
                        })
                    }
                }
            }
        ]
    },
    plugins: [
        new ExtractTextPlugin("styles/style.css")
    ]
}
```

vue内部的style需要先抽取出来，所以要在fallback属性上添加预先的加载器 'vue-style-loader'，'vue-style-

loader'是vue-loader自带的，如果运行时报错的话那就手动install一下。这样的话构建后的目录中会多出

styles目录。同时页面中会以link标签引入css。通常我们定义俩个实例，一个实例用来分离外部的css文件，另一

来分离vue内部的css，当然外部的一般可以复用我们不将其抽离到一个文件里，设置allChunks:false，vue内部的

相反，设置allChunks:true即可

####  	  6 多次引用的模块单独打包

​	多次引用的模块单独打包避免重复打包就需要用到 [CommonsChunkPlugin](http://link.zhihu.com/?target=https%3A//webpack.js.org/plugins/commons-chunk-plugin/) 这个插件。webpack.config.js 就变成这样了：

```js
module.exports = {
    entry: {
        app: './src/main.js',
        vendor: ['vue',
            'axio',
            'vue-router',
            'vuex',
            'element-ui',
        // 很长很长],
    }
```

我们每次引入了新的第三方库,都需要在 vendor 手动增加对应的包名,就引入自动化分离vendor,minChunks插件

可以参考下饿了么的这个demo进行模块自动提取打包。简单明了通俗易懂

[饿了么前端(Code Splitting)](https://zhuanlan.zhihu.com/p/26710831)

#### 7  JS代码压缩

​	js代码的压缩，也就是常常的UglifyJs，同样先安装再配置

```js
const UglifyJsPlugin = require('uglifyjs-webpack-plugin')
new UglifyJsPlugin({
    uglifyOptions: {
        compress: {
            warnings: false   //去除警告
        }
    },
    sourceMap: true           //开启源码映射
})
```

#### 8 通过内置的keep-alive缓存也是加快页面加载的一种方法

####  9 服务端渲染替代客户端渲染

------

​	最后推荐看一下这三篇文章，可以从头到尾更加理解vue-cli和webpack的配置和工作原理，里面也包含了很多缩小打包文件的方法

[从搭建vue-脚手架到掌握webpack配置（一.基础配置）](https://www.jianshu.com/p/f05269760d84)

[从搭建vue-脚手架到掌握webpack配置（二.插件与提取)](https://www.jianshu.com/p/3d64a4e9457f)

[从搭建vue-脚手架到掌握webpack配置（三.多页面构建）](https://www.jianshu.com/p/ff544834c478)

