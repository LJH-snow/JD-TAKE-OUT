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

	// 定义测试函数
	testFunc := func(name string, url string) {
		fmt.Printf("\n=== 测试 %s ===\n", name)
		fmt.Printf("URL: %s\n", url)

		req, err := http.NewRequest("GET", url, nil)
		if err != nil {
			log.Printf("创建请求失败: %v", err)
			return
		}

		req.Header.Set("Authorization", "Bearer "+token)

		client := &http.Client{Timeout: 10 * time.Second}
		resp, err := client.Do(req)
		if err != nil {
			log.Printf("请求失败: %v", err)
			return
		}
		defer resp.Body.Close()

		body, err := io.ReadAll(resp.Body)
		if err != nil {
			log.Printf("读取响应失败: %v", err)
			return
		}

		var result map[string]interface{}
		if err := json.Unmarshal(body, &result); err != nil {
			log.Printf("解析响应失败: %v", err)
			return
		}

		prettyJSON, err := json.MarshalIndent(result, "", "  ")
		if err != nil {
			log.Printf("格式化JSON失败: %v", err)
			return
		}

		fmt.Printf("状态码: %d\n", resp.StatusCode)
		fmt.Printf("响应: %s\n", prettyJSON)
	}

	// --- 测试近7天 ---
	fmt.Println("\n\n================== 开始测试【近7天】数据 ==================")
	today := time.Date(2025, 9, 9, 0, 0, 0, 0, time.UTC)
	sevenDaysAgo := today.AddDate(0, 0, -6)
	start7 := sevenDaysAgo.Format("2006-01-02")
	end7 := today.Format("2006-01-02")

	testFunc("工作台概览 (近7天)", fmt.Sprintf("http://localhost:8090/api/v1/admin/dashboard/overview?start=%s&end=%s", start7, end7))

	// --- 测试近30天 ---
	fmt.Println("\n\n================== 开始测试【近30天】数据 ==================")
	thirtyDaysAgo := today.AddDate(0, 0, -29)
	start30 := thirtyDaysAgo.Format("2006-01-02")
	end30 := today.Format("2006-01-02")

	testFunc("工作台概览 (近30天)", fmt.Sprintf("http://localhost:8090/api/v1/admin/dashboard/overview?start=%s&end=%s", start30, end30))
}