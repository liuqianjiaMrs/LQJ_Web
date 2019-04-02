//
//  GuideViewController.m
//  路线导航1
//
//  Created by 刘倩佳 on 16/8/26.
//  Copyright © 2016年 刘倩佳. All rights reserved.
//

#import "GuideViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "KCAnnotation.h"
@interface GuideViewController ()<MKMapViewDelegate>
{
    MKMapView *mapview;
    CLLocationManager *locationManager;
    MKRoute *route;
    MKPolygonView *ploygonView;
}
@property (nonatomic, strong) CLGeocoder *geoC;

@end

@implementation GuideViewController
#pragma mark -懒加载
-(CLGeocoder *)geoC
{
    if (!_geoC) {
        _geoC = [[CLGeocoder alloc] init];
    }
    return _geoC;
}
- (void)viewDidLoad {
    [super viewDidLoad];
//  添加地图控件
    mapview = [[MKMapView alloc]initWithFrame:CGRectMake(20, 20, self.view.frame.size.width-40, 280)];
     [self.view addSubview:mapview];
    mapview.backgroundColor = [UIColor blueColor];
//    用户位置追踪（用户位置追踪用于标记用户当前位置，此时会调用定位服务）
    mapview.userTrackingMode = MKUserTrackingModeFollow;

    mapview.delegate = self;
    mapview.mapType = MKMapTypeStandard;
    
    //请求定位服务
    locationManager=[[CLLocationManager alloc]init];
    if(![CLLocationManager locationServicesEnabled]||[CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorizedWhenInUse){
        [locationManager requestWhenInUseAuthorization];
    }
    [self addAnnotation];
//    [self turnByTurn];
//    请求路线
    
    
    
  }
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    
//    
//    // 测试, 添加圆形覆盖层
//    // == 添加圆形覆盖层 数据模型
//    
//    // 创建一个圆形的覆盖层数据模型
//    MKCircle *circle = [MKCircle circleWithCenterCoordinate:mapview.centerCoordinate radius:100000];
//    
//    [mapview addOverlay:circle];
//}
-(void)addAnnotation
{
    CLLocationCoordinate2D currentLocation = CLLocationCoordinate2DMake(39.54, 116.28);
    KCAnnotation *annotation1 = [[KCAnnotation alloc]init];
    annotation1.title = @"我的位置";
    annotation1.subtitle = @"北京颐和园";
    annotation1.coordinate = currentLocation;
    [mapview addAnnotation:annotation1];
   
    CLLocationCoordinate2D endLocation = CLLocationCoordinate2DMake(43.87, 129.49);
    KCAnnotation *annotation2 = [[KCAnnotation alloc]init];
    annotation2.title = @"最终位置";
    annotation2.subtitle = @"北京清华大学";
    annotation2.coordinate = endLocation;
    [mapview addAnnotation:annotation2];
    
    MKPlacemark *fromPlacemark = [[MKPlacemark alloc]initWithCoordinate:currentLocation addressDictionary: nil];
    MKPlacemark *toPlacemark = [[MKPlacemark alloc]initWithCoordinate:endLocation addressDictionary:nil];
    MKMapItem *fromItem = [[MKMapItem alloc]initWithPlacemark:fromPlacemark];
    MKMapItem *toItem = [[MKMapItem alloc]initWithPlacemark:toPlacemark];
    [self findDirectionsFrom:fromItem to:toItem];
}
-(void)findDirectionsFrom:(MKMapItem *)source to:(MKMapItem *)destination
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    request.source = source;
    request.destination = destination;
    request.requestsAlternateRoutes = YES;//如果路由服务器可以找出多条合理的路线，设置YES 将会返回所有路线。否则，只返回一条路线。
    MKDirections *directions = [[MKDirections alloc]initWithRequest:request];
////    计算路线花费的时间
//    [directions calculateETAWithCompletionHandler:^(MKETAResponse * _Nullable response, NSError * _Nullable error) {
//        
//        if (error) {
//            NSLog(@"error:%@",error);
//        }else
//        {
////            response.
//        }
//    }];
//    计算真实的路线
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        /**
         *  MKDirectionsResponse
         routes : 路线数组MKRoute
         
         */
        /**
         *  MKRoute
         name : 路线名称
         distance : 距离
         expectedTravelTime : 预期时间
         polyline : 折线(数据模型)
         steps
         */
        /**
         *  steps <MKRouteStep *>
         instructions : 行走提示
         */

        if (error) {
            
            NSLog(@"error:%@", error);
        }
        else {
            
//        route = response.routes[0];
            [response.routes enumerateObjectsUsingBlock:^(MKRoute * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSLog(@"%@--%zd--%f",obj.name,obj.distance,obj.expectedTravelTime);
                MKPolyline *poline = obj.polyline;
                [mapview addOverlay:poline];
            }];
//            [mapview addOverlay:route.polyline];
          
        }
    }];

}
//-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
//{
//    MKOverlayView* overlayView = nil;
//    
//    
//    
//    if(overlay == route.polyline)
//        
//    {
//        
//        //if we have not yet created an overlay view for this overlay, create it now.
//        
//        if(nil == route.polyline)
//            
//        {
//            
//            ploygonView = [[MKPolylineView alloc] initWithPolyline:route.polyline]  ;
//            
//             ploygonView.fillColor = [UIColor redColor];
//            
//            ploygonView.strokeColor = [UIColor redColor];
//            
//             ploygonView.lineWidth = 3;
//            
//        }
//        
//        
//        
//        overlayView = ploygonView;
//        
//        
//        
//    }
//    
//    
//    
//    return overlayView;
//    
// 
//}
/**
*  当我们添加一个覆盖层数据模型时, 系统就会调用这个方法查找对应的渲染图层
*
*  @param mapView 地图
*  @param overlay 覆盖层数据模型
*
*  @return 渲染层
*/
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    
//    MKCircleRenderer *render = [[MKCircleRenderer alloc] initWithOverlay:overlay];
//    
//    render.fillColor = [UIColor greenColor];
//    render.alpha = 0.6;
//    
//    return render;
    MKPolylineRenderer *render = [[MKPolylineRenderer alloc]initWithOverlay:overlay];
    render.lineWidth = 10;
    render.strokeColor = [UIColor orangeColor];
    return render;
}
//-(void)turnByTurn{
//    //根据“北京市”地理编码
//    [_geoC geocodeAddressString:@"北京市"completionHandler:^(NSArray*placemarks,NSError*error) {CLPlacemark*clPlacemark1=[placemarks firstObject];
//        //获取第一个地标
//        MKPlacemark *mkPlacemark1=[[MKPlacemark alloc]initWithPlacemark:clPlacemark1];
//        //注意地理编码一次只能定位到一个位置，不能同时定位，所在放到第一个位置定位完成回调函数中再次定位
//        [_geoC geocodeAddressString:@"郑州市"completionHandler:^(NSArray*placemarks,NSError*error) {CLPlacemark*clPlacemark2=[placemarks firstObject];
//        //获取第一个地标
//        MKPlacemark *mkPlacemark2=[[MKPlacemark alloc]initWithPlacemark:clPlacemark2];NSDictionary*options=@{MKLaunchOptionsMapTypeKey:@(MKMapTypeStandard),MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving};
////            MKMapItem *mapItem1=[MKMapItem mapItemForCurrentLocation];//当前位置
//            MKMapItem *mapItem1=[[MKMapItem alloc]initWithPlacemark:mkPlacemark1];
//            MKMapItem *mapItem2=[[MKMapItem alloc]initWithPlacemark:mkPlacemark2];            [MKMapItem openMapsWithItems:@[mapItem1,mapItem2] launchOptions:options];                    }];
//    }];
//    
//    }
@end
