#!/bin/bash

# Nameserver Propagation Check Script
# 检查 Cloudflare 域名激活状态

echo "🔍 检查 Cloudflare Zone 状态..."
echo ""

# 检查 zone status
STATUS=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/f5e0b4ee6e58c05fa25e4039a55de92b" \
  -H "X-Auth-Email: junqiaochen@gmail.com" \
  -H "X-Auth-Key: YOUR_API_KEY" | jq -r '.result.status')

echo "📍 Cloudflare Zone 状态: $STATUS"

if [ "$STATUS" = "active" ]; then
    echo "✅ 域名已激活！"
    echo "🎉 可以开始配置自定义域名了"
    echo ""
    echo "下一步: 运行域名配置脚本"
    exit 0
elif [ "$STATUS" = "pending" ]; then
    echo "⏳ 域名仍在等待 nameserver 传播"
    echo "📝 Nameservers:"
    echo "   - delilah.ns.cloudflare.com"
    echo "   - jaziel.ns.cloudflare.com"
    echo ""
    echo "预计时间: 2-24 小时"
    echo "💡 请稍后再试，或等待 Cloudflare 发送激活邮件"
else
    echo "❓ 未知状态: $STATUS"
fi

echo ""
echo "🌐 从外部 DNS 验证 nameservers:"
whois xiaojunhong.space | grep -i "name server" | head -2

echo ""
echo "🔗 检查域名解析:"
nslookup xiaojunhong.space | grep "Name:" -A 1
