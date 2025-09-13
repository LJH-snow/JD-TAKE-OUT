package controllers

import (
	"log"
	"net/http"
	"strconv"
	"time"

	"jd-take-out-backend/internal/models"
	"jd-take-out-backend/pkg/utils"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// ShoppingCartController 购物车控制器
type ShoppingCartController struct {
	DB *gorm.DB
}

// AddShoppingCartRequest 添加购物车请求体
type AddShoppingCartRequest struct {
	DishID    *uint   `json:"dish_id"`
	SetmealID *uint   `json:"setmeal_id"`
	DishFlavor string `json:"dish_flavor"`
	Number    int    `json:"number"` // 默认为1
}

// UpdateShoppingCartRequest 更新购物车请求体
type UpdateShoppingCartRequest struct {
	ID     uint `json:"id" binding:"required"`
	Number int  `json:"number" binding:"required"`
}

// AddShoppingCart 添加商品到购物车
// @Summary      添加商品到购物车
// @Description  添加菜品或套餐到用户的购物车
// @Tags         购物车
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        body body AddShoppingCartRequest true "添加购物车请求参数"
// @Success      200  {object}  map[string]interface{}  "添加成功"
// @Failure      400  {object}  map[string]interface{}  "请求参数错误"
// @Failure      404  {object}  map[string]interface{}  "商品不存在"
// @Failure      500  {object}  map[string]interface{}  "服务器错误"
// @Router       /api/v1/user/shoppingCart [post]
func (scc *ShoppingCartController) AddShoppingCart(c *gin.Context) {
	log.Printf("AddShoppingCart: Request received")
	var req AddShoppingCartRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		log.Printf("AddShoppingCart: Parameter binding failed: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "参数绑定失败: " + err.Error()})
		return
	}

	claims, exists := c.Get("claims")
	if !exists {
		log.Printf("AddShoppingCart: User not authenticated")
		c.JSON(http.StatusUnauthorized, gin.H{"code": 401, "message": "用户未认证"})
		return
	}
	userClaims := claims.(*utils.Claims)
	userID := userClaims.UserID
	log.Printf("AddShoppingCart: UserID: %d, DishID: %v, SetmealID: %v, Number: %d, Flavor: %s", userID, req.DishID, req.SetmealID, req.Number, req.DishFlavor)

	// 检查商品是否存在
	var name string
	var image string
	var amount float64

	if req.DishID != nil {
		var dish models.Dish
		if err := scc.DB.First(&dish, *req.DishID).Error; err != nil {
			log.Printf("AddShoppingCart: Dish not found: %v", err)
			c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "菜品不存在"})
			return
		}
		name = dish.Name
		image = dish.Image
		amount = dish.Price
	} else if req.SetmealID != nil {
		var setmeal models.Setmeal
		if err := scc.DB.First(&setmeal, *req.SetmealID).Error; err != nil {
			log.Printf("AddShoppingCart: Setmeal not found: %v", err)
			c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "套餐不存在"})
			return
		}
		name = setmeal.Name
		image = setmeal.Image
		amount = setmeal.Price
	} else {
		log.Printf("AddShoppingCart: DishID or SetmealID is empty")
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "菜品ID或套餐ID不能同时为空"})
		return
	}

	// 检查购物车中是否已存在该商品
	var shoppingCart models.ShoppingCart
	query := scc.DB.Where("user_id = ?", userID)
	if req.DishID != nil {
		query = query.Where("dish_id = ?", *req.DishID)
	} else {
		query = query.Where("setmeal_id = ?", *req.SetmealID)
	}
	if req.DishFlavor != "" {
		query = query.Where("dish_flavor = ?", req.DishFlavor)
	}

	if err := query.First(&shoppingCart).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			// 不存在，则新增
			log.Printf("AddShoppingCart: Item not found in cart, creating new. Current number: %d", req.Number)
			if req.Number == 0 { // 如果是新增且数量为0，则默认为1
				req.Number = 1
			}
			shoppingCart = models.ShoppingCart{
				Name:       name,
				Image:      image,
				UserID:     userID,
				DishID:     req.DishID,
				SetmealID:  req.SetmealID,
				DishFlavor: req.DishFlavor,
				Number:     req.Number,
				Amount:     amount,
				CreatedAt:  time.Now(),
				UpdatedAt:  time.Now(),
			}
			if err := scc.DB.Create(&shoppingCart).Error; err != nil {
				log.Printf("AddShoppingCart: Failed to create cart item: %v", err)
				c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "添加购物车失败"})
				return
			}
			log.Printf("AddShoppingCart: New cart item created: %+v", shoppingCart)
		} else {
			log.Printf("AddShoppingCart: Failed to query cart: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "查询购物车失败"})
			return
		}
	} else {
		// 已存在，则更新数量
		log.Printf("AddShoppingCart: Item found in cart, updating. Old number: %d, Add number: %d", shoppingCart.Number, req.Number)
		shoppingCart.Number += req.Number
		if shoppingCart.Number <= 0 { // 如果更新后数量小于等于0，则删除该项
			log.Printf("AddShoppingCart: Item number <= 0, deleting item: %d", shoppingCart.Number)
			if err := scc.DB.Delete(&shoppingCart).Error; err != nil {
				log.Printf("AddShoppingCart: Failed to delete cart item: %v", err)
				c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "移除购物车商品失败"})
				return
			}
			log.Printf("AddShoppingCart: Cart item deleted.")
		} else {
			shoppingCart.UpdatedAt = time.Now()
			if err := scc.DB.Save(&shoppingCart).Error; err != nil {
				log.Printf("AddShoppingCart: Failed to update cart item: %v", err)
				c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "更新购物车失败"})
				return
			}
			log.Printf("AddShoppingCart: Cart item updated: %+v", shoppingCart)
		}
	}

	log.Printf("AddShoppingCart: Operation successful. Response: %+v", shoppingCart)
	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "操作成功", "data": shoppingCart})
}

// GetShoppingCart 获取购物车内容
// @Summary      获取购物车内容
// @Description  获取当前用户的购物车列表
// @Tags         购物车
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Success      200  {object}  map[string]interface{}  "获取成功"
// @Failure      401  {object}  map[string]interface{}  "用户未认证"
// @Failure      500  {object}  map[string]interface{}  "服务器错误"
// @Router       /api/v1/user/shoppingCart [get]
func (scc *ShoppingCartController) GetShoppingCart(c *gin.Context) {
	log.Printf("GetShoppingCart: Request received")
	claims, exists := c.Get("claims")
	if !exists {
		log.Printf("GetShoppingCart: User not authenticated")
		c.JSON(http.StatusUnauthorized, gin.H{"code": 401, "message": "用户未认证"})
		return
	}
	userClaims := claims.(*utils.Claims)
	userID := userClaims.UserID
	log.Printf("GetShoppingCart: UserID: %d", userID)

	var shoppingCartItems []models.ShoppingCart
	if err := scc.DB.Where("user_id = ?", userID).Order("created_at DESC").Find(&shoppingCartItems).Error; err != nil {
		log.Printf("GetShoppingCart: Failed to retrieve cart items: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "获取购物车失败"})
		return
	}

	log.Printf("GetShoppingCart: Retrieved %d items for UserID %d", len(shoppingCartItems), userID)
	log.Printf("GetShoppingCart: Items: %+v", shoppingCartItems)
	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "获取成功", "data": shoppingCartItems})
}

// UpdateShoppingCart 更新购物车商品数量
// @Summary      更新购物车商品数量
// @Description  更新购物车中指定商品的数量
// @Tags         购物车
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        body body UpdateShoppingCartRequest true "更新购物车请求参数"
// @Success      200  {object}  map[string]interface{}  "更新成功"
// @Failure      400  {object}  map[string]interface{}  "请求参数错误"
// @Failure      401  {object}  map[string]interface{}  "用户未认证"
// @Failure      404  {object}  map[string]interface{}  "购物车商品不存在"
// @Failure      500  {object}  map[string]interface{}  "服务器错误"
// @Router       /api/v1/user/shoppingCart [put]
func (scc *ShoppingCartController) UpdateShoppingCart(c *gin.Context) {
	var req UpdateShoppingCartRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "参数绑定失败: " + err.Error()})
		return
	}

	claims, exists := c.Get("claims")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"code": 401, "message": "用户未认证"})
		return
	}
	userClaims := claims.(*utils.Claims)
	userID := userClaims.UserID

	var shoppingCart models.ShoppingCart
	if err := scc.DB.Where("id = ? AND user_id = ?", req.ID, userID).First(&shoppingCart).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "购物车商品不存在"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "查询购物车失败"})
		return
	}

	shoppingCart.Number = req.Number
	if shoppingCart.Number <= 0 { // 如果更新后数量小于等于0，则删除该项
		if err := scc.DB.Delete(&shoppingCart).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "移除购物车商品失败"})
			return
		}
	} else {
		shoppingCart.UpdatedAt = time.Now()
		if err := scc.DB.Save(&shoppingCart).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "更新购物车失败"})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "更新成功", "data": shoppingCart})
}

// RemoveShoppingCart 移除购物车商品
// @Summary      移除购物车商品
// @Description  从购物车中移除指定商品
// @Tags         购物车
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int  true  "购物车商品ID"
// @Success      200  {object}  map[string]interface{}  "移除成功"
// @Failure      400  {object}  map[string]interface{}  "请求参数错误"
// @Failure      401  {object}  map[string]interface{}  "用户未认证"
// @Failure      404  {object}  map[string]interface{}  "购物车商品不存在"
// @Failure      500  {object}  map[string]interface{}  "服务器错误"
// @Router       /api/v1/user/shoppingCart/{id} [delete]
func (scc *ShoppingCartController) RemoveShoppingCart(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "无效的ID格式"})
		return
	}

	claims, exists := c.Get("claims")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"code": 401, "message": "用户未认证"})
		return
	}
	userClaims := claims.(*utils.Claims)
	userID := userClaims.UserID

	var shoppingCart models.ShoppingCart
	if err := scc.DB.Where("id = ? AND user_id = ?", id, userID).First(&shoppingCart).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "购物车商品不存在"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "查询购物车失败"})
		return
	}

	if err := scc.DB.Delete(&shoppingCart).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "移除购物车商品失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "移除成功"})
}

// ClearShoppingCart 清空购物车
// @Summary      清空购物车
// @Description  清空当前用户的所有购物车商品
// @Tags         购物车
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Success      200  {object}  map[string]interface{}  "清空成功"
// @Failure      401  {object}  map[string]interface{}  "用户未认证"
// @Failure      500  {object}  map[string]interface{}  "服务器错误"
// @Router       /api/v1/user/shoppingCart/clear [delete]
func (scc *ShoppingCartController) ClearShoppingCart(c *gin.Context) {
	claims, exists := c.Get("claims")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"code": 401, "message": "用户未认证"})
		return
	}
	userClaims := claims.(*utils.Claims)
	userID := userClaims.UserID

	if err := scc.DB.Where("user_id = ?", userID).Delete(&models.ShoppingCart{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "清空购物车失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "清空成功"})
}
