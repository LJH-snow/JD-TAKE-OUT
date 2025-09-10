package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

func main() {
	fmt.Println("=== JWT Token测试演示 ===")

	// 1. 首先登录获取Token
	loginData := map[string]string{
		"username":  "admin",
		"password":  "admin123",
		"user_type": "admin",
	}

	loginJSON, _ := json.Marshal(loginData)

	fmt.Println("1. 正在登录获取Token...")
	resp, err := http.Post("http://localhost:8090/api/v1/auth/login",
		"application/json", bytes.NewBuffer(loginJSON))
	if err != nil {
		fmt.Printf("登录请求失败: %v\n", err)
		return
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)

	if resp.StatusCode != 200 {
		fmt.Printf("登录失败，状态码: %d, 响应: %s\n", resp.StatusCode, body)
		return
	}

	var loginResp map[string]interface{}
	json.Unmarshal(body, &loginResp)

	data, ok := loginResp["data"].(map[string]interface{})
	if !ok {
		fmt.Printf("响应格式错误: %s\n", body)
		return
	}

	token, ok := data["token"].(string)
	if !ok {
		fmt.Printf("未找到token: %s\n", body)
		return
	}

	fmt.Printf("✅ 登录成功！获取到Token: %s...\n", token[:50])

	// 2. 使用Token访问需要认证的API
	fmt.Println("\n2. 使用Token访问工作台概览API...")

	req, _ := http.NewRequest("GET", "http://localhost:8090/api/v1/admin/dashboard/overview", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp2, err := client.Do(req)
	if err != nil {
		fmt.Printf("API请求失败: %v\n", err)
		return
	}
	defer resp2.Body.Close()

	body2, _ := io.ReadAll(resp2.Body)

	if resp2.StatusCode == 200 {
		fmt.Printf("✅ API访问成功！响应: %s\n", body2)
	} else {
		fmt.Printf("❌ API访问失败，状态码: %d, 响应: %s\n", resp2.StatusCode, body2)
	}

	// 3. 展示正确的Swagger使用方法
	fmt.Println("\n=== Swagger使用指南 ===")
	fmt.Println("在Swagger中使用Token的正确方法：")
	fmt.Println("1. 点击页面右上角的 🔒 'Authorize' 按钮")
	fmt.Printf("2. 在Value字段中输入: Bearer %s\n", token)
	fmt.Println("3. 点击 'Authorize' 按钮确认")
	fmt.Println("4. 现在所有需要认证的API都会自动携带这个Token")
	fmt.Println()
	fmt.Println("⚠️  注意：Token前面必须加上 'Bearer ' (注意Bearer后有一个空格)")
	fmt.Printf("   完整格式: Bearer %s\n", token)
}
