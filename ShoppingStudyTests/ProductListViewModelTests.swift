//
//  ProductListViewModelTests.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 21.09.2025.
//

import XCTest
import Combine
@testable import ShoppingStudy

@MainActor
final class ProductListViewModelTests: XCTestCase {
    var sut: ProductListViewModel!
    var mockProductService: MockProductService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockProductService = MockProductService()
        sut = ProductListViewModel(productService: mockProductService)
        cancellables = []
    }
    
    func testLoadProductsSuccess() async {
        // Given
        let expectedProducts = [
            Product(id: 1, title: "Product 1", price: 10.0, description: "Desc", 
                   category: "test", image: "img.jpg", rating: Product.Rating(rate: 4.0, count: 10)),
            Product(id: 2, title: "Product 2", price: 20.0, description: "Desc", 
                   category: "test", image: "img.jpg", rating: Product.Rating(rate: 3.5, count: 5))
        ]
        mockProductService.mockProducts = expectedProducts
        
        // When
        await sut.loadProducts()
        
        // Then
        XCTAssertEqual(sut.products.count, 2)
        XCTAssertEqual(sut.filteredProducts.count, 2)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }
    
    func testSearchFilter() async {
        // Given
        let products = [
            Product(id: 1, title: "iPhone", price: 999.0, description: "Phone", 
                   category: "electronics", image: "img.jpg", rating: Product.Rating(rate: 4.5, count: 100)),
            Product(id: 2, title: "Samsung", price: 899.0, description: "Phone", 
                   category: "electronics", image: "img.jpg", rating: Product.Rating(rate: 4.0, count: 80))
        ]
        mockProductService.mockProducts = products
        await sut.loadProducts()
        
        // When
        sut.searchText = "iPhone"
        
        // Wait for debounce
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Then
        XCTAssertEqual(sut.filteredProducts.count, 1)
        XCTAssertEqual(sut.filteredProducts.first?.title, "iPhone")
    }
    
    func testSortByPriceAscending() async {
        // Given
        let products = [
            Product(id: 1, title: "Expensive", price: 100.0, description: "", 
                   category: "test", image: "", rating: Product.Rating(rate: 4.0, count: 10)),
            Product(id: 2, title: "Cheap", price: 10.0, description: "", 
                   category: "test", image: "", rating: Product.Rating(rate: 4.0, count: 10))
        ]
        mockProductService.mockProducts = products
        await sut.loadProducts()
        
        // When
        sut.sortOption = .priceAsc
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Then
        XCTAssertEqual(sut.filteredProducts.first?.price, 10.0)
        XCTAssertEqual(sut.filteredProducts.last?.price, 100.0)
    }
}
