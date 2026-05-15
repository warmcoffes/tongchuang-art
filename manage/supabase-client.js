(() => {
  function hasConfig() {
    return Boolean(window.SUPABASE_URL && window.SUPABASE_ANON_KEY);
  }

  function getClient() {
    if (!window.supabase || !window.supabase.createClient) {
      throw new Error("Supabase SDK 未加载");
    }
    if (!hasConfig()) {
      throw new Error("Supabase 配置未完成");
    }
    if (!window.__tcSupabaseClient) {
      window.__tcSupabaseClient = window.supabase.createClient(
        window.SUPABASE_URL,
        window.SUPABASE_ANON_KEY
      );
    }
    return window.__tcSupabaseClient;
  }

  function formatError(error) {
    if (!error) return "发生未知错误";
    if (typeof error === "string") return error;
    if (error.message) return error.message;
    return "请求失败，请稍后再试";
  }

  async function getSession() {
    const client = getClient();
    const { data, error } = await client.auth.getSession();
    if (error) throw error;
    return data.session;
  }

  window.tcManage = {
    hasConfig,
    getClient,
    getSession,
    formatError,
  };
})();
