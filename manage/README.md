# 管理模块接入 Supabase

这一版后台按手机操作优先设计，主线只有四件事：

1. 录入学员
2. 记录缴费
3. 签到扣课
4. 查询剩余

## 需要准备

1. 一个 Supabase 项目
2. 项目的 `Project URL`
3. 项目的 `anon public key`
4. 一个内部使用的管理员账号

## 第一步：建表

在 Supabase Dashboard 的 SQL Editor 中运行：

- `supabase-schema.sql`

它会创建三张表：

- `students`
- `payments`
- `lesson_logs`

同时会：

- 开启 RLS
- 只允许 `authenticated` 用户读写
- 自动在签到后扣减剩余课时

## 第二步：放前端配置

复制一份：

- `supabase-config.example.js`

改名为：

- `supabase-config.js`

然后把里面两项改成你自己的：

- `window.SUPABASE_URL`
- `window.SUPABASE_ANON_KEY`

## 第三步：前端接入

浏览器端可以直接用 Supabase 官方 CDN：

```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script src="./supabase-config.js"></script>
```

然后初始化：

```js
const supabase = window.supabase.createClient(
  window.SUPABASE_URL,
  window.SUPABASE_ANON_KEY
);
```

## 建议的登录方式

第一版最适合用 Supabase Auth 的邮箱登录，只给你自己或内部老师开账号。

这样：

- 手机上可以直接登录
- 数据不会暴露给公开访问的人
- RLS 可以直接按 `authenticated` 用户控制

## 第一版应该先接的页面

优先顺序建议：

1. `new.html`
   - 保存到 `students`
2. `students.html`
   - 读取 `students`
3. `checkin.html`
   - 写入 `lesson_logs`
   - 自动扣课时
4. `payments.html`
   - 写入 `payments`

## 手机端使用原则

- 一页完成录入
- 大输入框
- 搜索放顶部
- 按钮至少 44px 高
- 签到尽量做到一键完成

## 官方参考

- Supabase JS CDN: https://supabase.com/docs/reference/javascript/installing
- RLS: https://supabase.com/docs/guides/database/postgres/row-level-security
- Pricing: https://supabase.com/pricing
