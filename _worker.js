/**
 * Welcome to Cloudflare Workers! This is your first worker.
 *
 * - Run "npm run dev" in your terminal to start a development server
 * - Open a browser tab at http://localhost:8787/ to see your worker in action
 * - Run "npm run deploy" to publish your worker
 *
 * Learn more at https://developers.cloudflare.com/workers/
 */

export default {
	async fetch(request, env) {
	  // 从环境变量中读取目标检测地址（例如你要检测的服务器/接口URL）
	  const target = env.TARGET_URL;
  
	  // 初始化检测结果标志，默认设为 false（离线）
	  let ok = false;
  
	  // 如果没有配置 TARGET_URL 环境变量
	  // 直接返回 offline，并提示错误信息（避免误判为在线）
	  if (!target) {
		return new Response(
		  JSON.stringify({
			server: "offline",           // 标记为离线
			error: "TARGET_URL not set"  // 返回错误原因
		  }),
		  { headers: { "content-type": "application/json" } } // 返回 JSON 格式
		);
	  }
  
	  try {
		// 向目标地址发起 GET 请求
		// cf.timeout = 5 表示 Cloudflare 边缘网络层超时控制（单位秒）
		const resp = await fetch(target, { method: "GET", cf: { timeout: 5 } });
		
		// 判断响应是否成功（HTTP 状态码 200-299）
		ok = resp.ok;
	  } catch (e) {
		// 如果请求异常（超时 / 网络错误 / DNS失败等）
		// 直接判定为离线
		ok = false;
	  }
  
	  // 返回最终检测结果（online 或 offline）
	  return new Response(
		JSON.stringify({ server: ok ? "online" : "offline" }) + "\n", // 输出JSON并换行
		{ headers: { "content-type": "application/json" } } // 设置返回类型为JSON
	  );
	  
	}
  };