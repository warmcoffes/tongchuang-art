(() => {
  async function requireSession(options = {}) {
    const { redirect = true } = options;
    const session = await window.tcManage.getSession();
    if (!session && redirect) {
      const next = encodeURIComponent(location.pathname.split("/").slice(-1)[0] || "index.html");
      location.href = `login.html?next=${next}`;
      return null;
    }
    return session;
  }

  async function signOut() {
    const client = window.tcManage.getClient();
    const { error } = await client.auth.signOut();
    if (error) throw error;
  }

  window.tcAuth = {
    requireSession,
    signOut,
  };
})();
