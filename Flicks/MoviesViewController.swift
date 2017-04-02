//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Nishant nishanko on 3/30/17.
//  Copyright © 2017 Nishant nishanko. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate{

    @IBOutlet weak var movieCollectinView: UICollectionView!
    @IBOutlet weak var moviesSegmentedControl: UISegmentedControl!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var movies: [NSDictionary]?
    var endPoint: String!
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if let movies = movies{
            return movies.count
            
        }else{
            return 0
        }

    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let baseurl = "https://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String{
            let imageUrl = URL(string: baseurl+posterPath)
            cell.posterView.setImageWith(imageUrl!)
            
        }
        cell.titleView.text = title

        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let movies = movies{
            return movies.count
            
        }else{
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let baseurl = "https://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String{
            let imageUrl = URL(string: baseurl+posterPath)
            cell.posterView.setImageWith(imageUrl!)
            
        }
        
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        //        cell.overviewLabel.sizeToFit()
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated:true)
    }

    
    func moviesSegmentControl (_ moviesSegmentedControl: UISegmentedControl){
        print(moviesSegmentedControl.selectedSegmentIndex)
        if( moviesSegmentedControl.selectedSegmentIndex == 0){
            self.tableView.isHidden = false;
            self.movieCollectinView.isHidden = true;
        }else{
            self.tableView.isHidden = true;
            self.movieCollectinView.isHidden = false;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(moviesSegmentedControl.selectedSegmentIndex)
        tableView.dataSource = self
        tableView.delegate = self
        movieCollectinView.dataSource = self
        movieCollectinView.delegate = self
        
        errorView.isHidden = true
        if( moviesSegmentedControl.selectedSegmentIndex == 0){
            self.tableView.isHidden = false;
            self.movieCollectinView.isHidden = true;
        }else{
            self.tableView.isHidden = true;
            self.movieCollectinView.isHidden = false;
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        
        moviesSegmentedControl.addTarget(self, action: #selector(moviesSegmentControl(_:)), for: UIControlEvents.valueChanged)
        
        tableView.insertSubview(refreshControl, at: 0)
        let urlString = "https://api.themoviedb.org/3/movie/"+endPoint+"?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string:urlString)
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        MBProgressHUD.showAdded(to: self.view, animated: true)

        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if (error != nil){
                    self.errorView.isHidden = false;
                    self.tableView.isHidden = true;
                    self.moviesSegmentedControl.isHidden = true;
                    MBProgressHUD.hide(for: self.view, animated: true)
                }else{
                    let when = DispatchTime.now() + 1 // delay to simulate loading wait time to show loader
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        if let data = data {
                            if let responseDictionary = try! JSONSerialization.jsonObject(
                                with: data, options:[]) as? NSDictionary {
                                
                                self.movies = responseDictionary["results"] as? [NSDictionary]
                                self.tableView.reloadData()
                                self.movieCollectinView.reloadData()
                                MBProgressHUD.hide(for: self.view, animated: true)
                            }
                        }
                    }
                }

        });
        task.resume()

        // Do any additional setup after loading the view.
    }
    
    
    func refreshControlAction(_ refreshControl: UIRefreshControl){
        let urlString = "https://api.themoviedb.org/3/movie/"+self.endPoint+"?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"
        
        let url = URL(string:urlString)
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )

        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                
                let when = DispatchTime.now() + 1 // delay to simulate loading wait time to show loader
                DispatchQueue.main.asyncAfter(deadline: when) {
                    if let data = data {
                        if let responseDictionary = try! JSONSerialization.jsonObject(
                            with: data, options:[]) as? NSDictionary {
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                            self.tableView.reloadData()
                            refreshControl.endRefreshing()
                            
                        }
                    }
                }
        });
        task.resume()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var indexPath: IndexPath!
        
        if moviesSegmentedControl.selectedSegmentIndex == 0 {
             let cell = sender as! UITableViewCell
             indexPath = tableView.indexPath(for: cell)
        } else {
            let cell = sender as! UICollectionViewCell
            indexPath = movieCollectinView.indexPath(for: cell)
        }

        let movie = movies?[(indexPath?.row)!]
        let destinationViewController = segue.destination as! DetailViewController
        destinationViewController.movie = movie
 
    }
    
}
