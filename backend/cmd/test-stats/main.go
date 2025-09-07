package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"strings"
	"time"
)

func main() {
	// 先登录获取token
	loginData := `{"username": "admin", "password": "admin123"}`
	resp, err := http.Post("http://localhost:8090/api/v1/auth/login", "application/json", strings.NewReader(loginData))
	if err != nil {
		log.Fatal("登录失败:", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Fatal("读取登录响应失败:", err)
	}

	var loginResp map[string]interface{}
	if err := json.Unmarshal(body, &loginResp); err != nil {
		log.Fatal("解析登录响应失败:", err)
	}

	// 提取token
	data, ok := loginResp["data"].(map[string]interface{})
	if !ok {
		log.Fatal("登录响应格式错误")
	}

	token, ok := data["token"].(string)
	if !ok {
		log.Fatal("未获取到token")
	}

	fmt.Printf("登录成功，获取到token: %s...\n", token[:20])

	// 测试统计API
	testAPIs := []struct {
		Name string
		URL  string
	}{
		{"工作台概览", "http://localhost:8090/api/v1/admin/dashboard/overview"},
		{"销售趋势", "http://localhost:8090/api/v1/admin/stats/sales?start=2025-09-01&end=2025-09-07"},
		{"菜品排行", "http://localhost:8090/api/v1/admin/stats/dishes?start=2025-09-01&end=2025-09-07&limit=5"},
		{"分类统计", "http://localhost:8090/api/v1/admin/stats/categories?start=2025-09-01&end=2025-09-07"},
	}

	for _, api := range testAPIs {
		fmt.Printf("\n=== 测试 %s ===\n", api.Name)

		req, err := http.NewRequest("GET", api.URL, nil)
		if err != nil {
			log.Printf("创建请求失败: %v", err)
			continue
		}

		req.Header.Set("Authorization", "Bearer "+token)

		client := &http.Client{Timeout: 10 * time.Second}
		resp, err := client.Do(req)
		if err != nil {
			log.Printf("请求失败: %v", err)
			continue
		}
		defer resp.Body.Close()

		body, err := io.ReadAll(resp.Body)
		if err != nil {
			log.Printf("读取响应失败: %v", err)
			continue
		}

		var result map[string]interface{}
		if err := json.Unmarshal(body, &result); err != nil {
			log.Printf("解析响应失败: %v", err)
			continue
		}

		// 美化输出
		prettyJSON, err := json.MarshalIndent(result, "", "  ")
		if err != nil {
			log.Printf("格式化JSON失败: %v", err)
			continue
		}

		fmt.Printf("状态码: %d\n", resp.StatusCode)
		fmt.Printf("响应: %s\n", prettyJSON)
	}
}
